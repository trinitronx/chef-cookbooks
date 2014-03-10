#!/usr/bin/env python
# This script is based off of the library found here: https://code.google.com/p/libsrvrmgrd-osx/
import urllib2, base64, sys, re, socket, ssl, httplib, plistlib

# Collect command line arguments
systemstat = sys.argv[1]
hostname = sys.argv[2]
webuser = sys.argv[3]
webpass = sys.argv[4]
warning = int(sys.argv[5])
critical = int(sys.argv[6])
# The URL to retrieve the system information
url = 'https://' + hostname + ':311/commands/servermgr_info?input=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22UTF-8%22%3F%3E%0D%0A%3Cplist+version%3D%220.9%22%3E%0D%0A%3Cdict%3E%0D%0A%09%3Ckey%3Ecommand%3C%2Fkey%3E%0D%0A%09%3Cstring%3EgetHardwareInfo%3C%2Fstring%3E%0D%0A%09%3Ckey%3Evariant%3C%2Fkey%3E%0D%0A%09%3Cstring%3EwithQuotaUsage%3C%2Fstring%3E%0D%0A%3C%2Fdict%3E%0D%0A%3C%2Fplist%3E%0D%0A&send=Send+Command'

# Replacement for broken clients https connect using non v1 connections
def httpsConnectReplacement(self):
	import socket, ssl
	sock = socket.create_connection((self.host, self.port), self.timeout, self.source_address)
	if self._tunnel_host:
		self.sock = sock
		self._tunnel()
	self.sock = ssl.wrap_socket(sock, self.key_file, self.cert_file, ssl_version=ssl.PROTOCOL_TLSv1)

# Get the hardware information from the OS X server
httplib.HTTPSConnection.connect = httpsConnectReplacement
from urllib2 import (HTTPPasswordMgr, HTTPBasicAuthHandler, build_opener, install_opener, urlopen, HTTPError)
password_mgr = HTTPPasswordMgr()	#WithDefaultRealm()
password_mgr.add_password("Server Admin", url, webuser, webpass)
handler = HTTPBasicAuthHandler(password_mgr)
opener = build_opener(handler)
install_opener(opener)
request =  urllib2.Request(url)
if webuser:
	base64string = base64.encodestring('%s:%s' % (webuser, webpass))[:-1]
	request.add_header("Authorization", "Basic %s" % base64string)
	request.add_header('WWW-Authenticate', 'Basic realm="Server Admin"')
try:
  htmlFile = urllib2.urlopen(request) #, timeout=30)
  htmlData = htmlFile.read()
  htmlFile.close()
  # This bit identifies if it's leopard which adds extra unneeded info as a header
  if re.match("SupportsBinaryPlist", htmlData):
    xmlDump = re.split("\r\n\r\n", htmlData, 1)
    response_xml = xmlDump[1]
  else:
    response_xml = htmlData
except:
	print sys.exc_info()[1]
# Read the plist response
server_data = plistlib.readPlistFromString(response_xml)

# CPU usage
if systemstat == "cpuUsage":
	cpuUsage = int(server_data["cpuUsageBy100"] / 100)
	if cpuUsage >= critical:
		status = "CRITICAL: "
		exit_code = 2
	elif cpuUsage >= warning:
		status = "WARNING: "
		exit_code = 1
	else:
		status = "OK: "
		exit_code = 0
	print status + "CPU usage: %(cpu)d%% |cpuUsage=%(cpu)d;;;;;" % { 'cpu': cpuUsage }
	sys.exit(exit_code)
# Disk usage
elif systemstat == "diskUsage":
	critical_count = 0
	warning_count = 0
	diskUsage = ""
	diskUsagePerf = ""
	# Loop through each of the individual volumes
	for item in server_data["volumeInfosArray"]:
		diskUsed = (100 * (item["totalBytes"] - item["freeBytes"])/item["totalBytes"])
		if diskUsed >= critical:
			critical_count += 1
			disk_status = " critical"
		elif diskUsed >= warning:
			warning_count += 1
			disk_status = " warning"
		else:
			disk_status = ""
		diskUsage += "%(name)s: %(pct)d%%%(sts)s, " % { 'name': item["name"], "pct": diskUsed, "sts": disk_status }
		diskUsagePerf += "totalBytes.%(name)s=%(total)d;;;;; freeBytes.%(name)s=%(free)d;;;;; usedBytes.%(name)s=%(used)d;;;;;" % { 'name': item["name"], "total": item["totalBytes"], "free": item["freeBytes"], "used": (item["totalBytes"] - item["freeBytes"]) }

	if critical_count > 0:
		status = "CRITICAL: "
		exit_code = 2
	elif warning_count > 0:
		status = "WARNING: "
		exit_code = 1
	else:
		status = "OK: "
		exit_code = 0
	print status + "Disk Usage: " + diskUsage[:-2] + " |" + diskUsagePerf
	sys.exit(exit_code)