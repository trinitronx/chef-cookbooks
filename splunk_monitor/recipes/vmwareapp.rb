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

service "splunk" do
  action [ :nothing ]
  supports :status => true, :start => true, :stop => true, :restart => true
end

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
      notifies :restart, resources(:service => "SplunkForwarder")
    end
  end
end

directory "#{node['splunk']['server_home']}/etc/apps/Splunk_TA_vcenter/local" do
  action :create
end

# Look for the vCenter host nodes
vcenternodes = search(:node, "role:vcenter_host")

template "#{node['splunk']['server_home']}/etc/apps/Splunk_TA_vcenter/local/props.conf" do
  source "vcenter_ta_local-props.conf.erb"
  variables ({
    :vcenter_nodes => vcenternodes
  })
  notifies :restart, resources(:service => "splunk")
end


