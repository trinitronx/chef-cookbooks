#
# Cookbook Name:: splunk_monitor
# Recipe:: nagiosapp 
#
# Copyright 2013, Biola University 
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

# Setting the file to download locally and install, so that version upgrades (or
# downgrades) will trigger app reinstallation

service "splunk" do
  action [ :nothing ]
  supports :status => true, :start => true, :stop => true, :restart => true
end

nagiosappfile = node['splunk']['apps']['nagiosapp_url'].split('/').last

if not File.directory?("#{node['splunk']['server_home']}/etc/apps/SplunkForNagios")
  remote_file "#{node['splunk']['server_home']}/etc/apps/" + nagiosappfile do
    source node['splunk']['apps']['nagiosapp_url']
    checksum node['splunk']['apps']['nagiosapp_checksum']
  end
  execute "install_nagios_app" do
    cwd "#{node['splunk']['server_home']}/etc/apps/"
    command "tar xzf " + nagiosappfile
    notifies :restart, resources(:service => "splunk")
  end
  file "#{node['splunk']['server_home']}/etc/apps/" + nagiosappfile do
    action :delete
  end
end