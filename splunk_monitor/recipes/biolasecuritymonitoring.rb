#
# Cookbook Name:: splunk_monitor
# Recipe:: biolasecuritymonitoring 
#
# Copyright 2012, Biola University 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ta_url = "https://github.com/biola/ta-biola_security_monitoring/tarball/v1.0"
ta_filename = "TA-biola_security_monitoring-v1.0.tar.gz"
ta_checksum = "699a2e0c8dc96e2c32726a14cf8edc1999f04564ce1d743bbd24aa0082557935"
# When grabbing tarballs directly from github, repo's contents are tar'd up inside 
# an additional directory with a user prefix and commit suffix. This needs to be stripped for
# the splunk install to work correctly; specify the directory name here so that Chef
# will do it automatically.
#
# This ta_tardirectory corresponds to the v1.0 version (git tag)
ta_tardirectory = "biola-ta-biola_security_monitoring-60b1f9c"



if File.exists?("#{node['splunk']['forwarder_home']}/bin/splunk") 
	splunk_cmd = "#{node['splunk']['forwarder_home']}/bin/splunk"
	if not File.directory?("#{node['splunk']['forwarder_home']}/etc/apps/TA-biola_security_monitoring") 
		remote_file "/tmp/" + ta_filename do 
			source ta_url
			checksum ta_checksum
		end
		execute "extract_ta_download" do
			command "tar -zxf /tmp/" + ta_filename
			cwd "/tmp"
		end
		execute "repack_ta_download" do
			command "tar -zcf /opt/" + ta_filename + " ./*" 
			cwd "/tmp/" + ta_tardirectory
		end
		execute "install_ta" do
			command splunk_cmd + " install app /opt/" + ta_filename + " -auth " + node['splunk']['auth']
		end
	end
else 
	if File.exists?("#{node['splunk']['server_home']}/bin/splunk") 
		splunk_cmd = "#{node['splunk']['server_home']}/bin/splunk"
		if not File.directory?("#{node['splunk']['server_home']}/etc/apps/TA-biola_security_monitoring") 
			remote_file "/tmp/" + ta_filename do 
				source ta_url
				checksum ta_checksum
			end
		execute "extract_ta_download" do
			command "tar -zxf /tmp/" + ta_filename
			cwd "/tmp"
		end
		execute "repack_ta_download" do
			command "tar -zcf /opt/" + ta_filename + " ./*" 
			cwd "/tmp/" + ta_tardirectory
		end
		execute "install_ta" do
			command splunk_cmd + " install app /opt/" + ta_filename + " -auth " + node['splunk']['auth']
		end
	end
end
end
