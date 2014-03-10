#
# Cookbook Name:: opsview
# Attributes:: client
#
# Copyright 2014, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE_2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform']
when "ubuntu"
  default['opsview']['agent_conf_dir'] = "/usr/local/nagios/etc/nrpe_local"
when "redhat", "centos"
  default['opsview']['agent_conf_dir'] = "/usr/local/nagios/etc/nrpe_local"
when "windows"
  default['opsview']['agent_conf_dir'] = "C:/Program Files/opsview/NSClient++"
end

default['opsview']['windows_agent_x64_url'] = "https://s3.amazonaws.com/opsview-agents/Windows/Opsview_Windows_Agent_x64.msi"
default['opsview']['windows_agent_Win32_url'] = "https://s3.amazonaws.com/opsview-agents/Windows/Opsview_Windows_Agent_Win32.msi"