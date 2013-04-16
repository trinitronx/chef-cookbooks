#
# Cookbook Name:: splunk_monitor
# Recipe:: vcenter_ta 
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

vcenter_tafile = node['splunk']['apps']['vcenter_ta_url'].split('/').last

if not File.exists?("c:/chef/" + vcenter_tafile) 
  if File.exists?("#{node['splunk']['forwarder_home']}/bin/splunk.exe") 
    splunk_cmd = "#{node['splunk']['forwarder_home']}/bin/splunk.exe"
    remote_file "c:/chef/" + vcenter_tafile do 
      source node['splunk']['apps']['vcenter_ta_url']
      checksum node['splunk']['apps']['vcenter_ta_checksum']
    end
    execute "install_vcenter_ta" do
      command "\"" + splunk_cmd + "\" install app c:/chef/" + vcenter_tafile + " -auth " + node['splunk']['auth']
    end
  end
end
