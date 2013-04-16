#
# Cookbook Name:: splunk_monitor
# Recipe:: vmwareapp 
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

vmwareappfile = node['splunk']['apps']['vmwareapp_url'].split('/').last

if not File.exists?("/opt/" + vmwareappfile) 
  if File.exists?("#{node['splunk']['server_home']}/bin/splunk") 
    splunk_cmd = "#{node['splunk']['server_home']}/bin/splunk"
    remote_file "/opt/" + vmwareappfile do 
      source node['splunk']['apps']['vmwareapp_url']
      checksum node['splunk']['apps']['vmwareapp_checksum']
    end
    execute "install_vmware_app" do
      command "unzip -d \'#{node['splunk']['server_home']}\' /opt/" + vmwareappfile
    end
    execute "restart_splunk" do
      command splunk_cmd + ' restart'
    end
  end
end
