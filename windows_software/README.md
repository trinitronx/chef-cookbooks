windows_software Cookbook
=========================

Cookbook to facilitate automated software installation on Windows

Attributes
----------

#### windows_software::wireshark
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['windows_software']['wireshark']['download_url']</tt></td>
    <td>String</td>
    <td>Download URL for your hosted winpcap installer</td>
    <td><tt>None</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['wireshark']['download_url_32bit']</tt></td>
    <td>String</td>
    <td>Optional 32-bit download URL for legacy systems</td>
    <td><tt>None</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['wireshark']['displayname']</tt></td>
    <td>String</td>
    <td>DisplayName string from Windows registry uninstall info</td>
    <td><tt>Wireshark 1.10.3 (64-bit)</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['wireshark']['displayname_32bit']</tt></td>
    <td>String</td>
    <td>Optional DisplayName string from Windows registry uninstall info for legacy systems</td>
    <td><tt>Wireshark 1.10.3</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['wireshark']['checksum']</tt></td>
    <td>String</td>
    <td>Optional SHA-256 checksum of the installer</td>
    <td><tt>f48abaeae7dcb7261c252e26a871d3dfca272c54ecab0709bf1213258c515035</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['wireshark']['checksum_32bit']</tt></td>
    <td>String</td>
    <td>Optional SHA-256 checksum of the installer for legacy systems</td>
    <td><tt>None</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['wireshark']['winpcap_url']</tt></td>
    <td>String</td>
    <td>Download URL for your hosted wireshark installer</td>
    <td><tt>None</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['wireshark']['winpcap_displayname']</tt></td>
    <td>String</td>
    <td>DisplayName string from Windows registry uninstall info</td>
    <td><tt>WinPcap 4.1.2</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['wireshark']['winpcap_checksum']</tt></td>
    <td>String</td>
    <td>SHA-256 checksum of the installer</td>
    <td><tt>e435984f0a52ec78e996200ddb2c8ec3359af87ec58d1bc611cc15789e68373d</tt></td>
  </tr>
</table>

#### windows_software::winscp
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['windows_software']['winscp']['download_url']</tt></td>
    <td>String</td>
    <td>Download URL for your hosted installer</td>
    <td><tt>http://sourceforge.net/projects/winscp/files/WinSCP/5.5.3/winscp553setup.exe/download</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['winscp']['displayname']</tt></td>
    <td>String</td>
    <td>DisplayName string from Windows registry uninstall info</td>
    <td><tt>WinSCP 5.5.3</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['winscp']['checksum']</tt></td>
    <td>String</td>
    <td>Optional SHA-256 checksum of the installer</td>
    <td><tt>2e921bbf950606c5b0c9a1e1bd701139abc61606933c07d8dfb03b7febdea066</tt></td>
  </tr>
</table>

#### windows_software::python2
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['windows_software']['python2']['download_url']</tt></td>
    <td>String</td>
    <td>Download URL for your hosted installer</td>
    <td><tt>https://www.python.org/ftp/python/2.7.6/python-2.7.6.amd64.msi</tt></td>
  </tr>
  <tr>
    <td><tt>['windows_software']['python2']['checksum']</tt></td>
    <td>String</td>
    <td>Optional SHA-256 checksum of the installer</td>
    <td><tt>3793cb8874f5e156a161239fea04ad98829d4ecf623d52d43513780837eb4807</tt></td>
  </tr>
</table>

Usage
-----
#### windows_software::wireshark

Upload installers for WinPcap & Wireshark to your web server, set the attributes noted above, and include `windows_software::wireshark` in your node's `run_list`

NOTE: Most WinPcap installers are not capable of silent installation. We recommend using the one bundled with the Windows version of nmap.

#### windows_software::winscp

Upload the WinSCP installer to your web server, set the attributes noted above, and include `windows_software::winscp` in your node's `run_list`

#### windows_software::python2

**NOTE:** Requires chef-client >= 11.12.0

Upload the Python2 installer to your web server, set the attributes noted above, and include `windows_software::python2` in your node's `run_list`

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
 Copyright 2014, Biola University 

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

