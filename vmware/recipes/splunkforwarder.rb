#
# Cookbook Name:: splunk
# Recipe:: forwarder
# 
# Copyright 2013, Biola University 
# Copyright 2011-2012, BBY Solutions, Inc.
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


splunk_cmd = "/home/splunkadmin/splunk/bin/splunk"
#splunk_package_version = "splunkforwarder-#{node['splunk']['forwarder_version']}-#{node['splunk']['forwarder_build']}"

service "splunk" do
  action [ :nothing ]
  supports :status => true, :start => true, :stop => true, :restart => true
end

if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support Search")
else
  role_name = node['splunk']['server_role']

  splunk_servers = search(:node, "role:#{role_name}")
end

if node['splunk']['ssl_forwarding'] == true
  directory "#{node['splunk']['forwarder_home']}/etc/auth/forwarders" do
    owner "root"
    group "root"
    action :create
  end
  
  [node['splunk']['ssl_forwarding_cacert'],node['splunk']['ssl_forwarding_servercert']].each do |cert|
    cookbook_file "#{node['splunk']['forwarder_home']}/etc/auth/forwarders/#{cert}" do
      source "ssl/forwarders/#{cert}"
      owner "root"
      group "root"
      mode "0755"
      notifies :restart, resources(:service => "splunk")
    end
  end

  # SSL passwords are encrypted when splunk reads the file.  We need to save the password.
  # We need to save the password if it has changed so we don't keep restarting splunk.
  # Splunk encrypted passwords always start with $1$
  ruby_block "Saving Encrypted Password (outputs.conf)" do
    block do
      outputsPass = `grep -m 1 "sslPassword = " #{node['splunk']['forwarder_home']}/etc/system/local/outputs.conf | sed 's/sslPassword = //'`
      if outputsPass.match(/^\$1\$/) && outputsPass != node['splunk']['outputsSSLPass']
        node['splunk']['outputsSSLPass'] = outputsPass
        node.save
      end
    end
  end
end

template "/home/splunkadmin/opt/splunk/etc/system/local/outputs.conf" do
	source "forwarder/outputs.conf.erb"
	owner "splunkadmin"
	group "splunkadmin"
	mode "0644"
	variables :splunk_servers => splunk_servers
	notifies :restart, resources(:service => "splunk")
end

# Set up vsphere data gathering

directory "/home/splunkadmin/opt/splunk/etc/apps/Splunk_TA_vmware/local" do
  owner "splunkadmin"
  group "splunkadmin"
end

unless File.exist?("/home/splunkadmin/opt/splunk/etc/apps/Splunk_TA_vmware/local/engine.template")

  execute "/sbin/service splunk stop" do
    ignore_failure true
  end
  
  # Populate variables containing the vsphere & esx host credentials
  data_bag_name = "service_accounts"
  vsphere_user_pass = Chef::EncryptedDataBagItem.load(data_bag_name, node['vmware']['splunk_vsphere_user'])['password']  
  esxhost_user_pass = Chef::EncryptedDataBagItem.load(data_bag_name, node['vmware']['splunk_esxhost_user'])['password']  
  
  # Add domain prefix if necessary
  if (Chef::EncryptedDataBagItem.load(data_bag_name, node['vmware']['splunk_vsphere_user'])['domain']) != nil
    vsphere_user = Chef::EncryptedDataBagItem.load(data_bag_name, node['vmware']['splunk_vsphere_user'])['domain'] + "\\" + node['vmware']['splunk_vsphere_user']
  else
    vsphere_user = node['vmware']['splunk_vsphere_user']
  end
  
  esxhost_user = node['vmware']['splunk_esxhost_user']
  
  
  if Chef::Config[:solo]
    Chef::Log.warn("This recipe uses search. Chef Solo does not support Search")
  else
    vmware_role_name = node['vmware']['vcenter_server_role']
    vc_host = search(:node, "role:#{vmware_role_name}")[0]['fqdn']
  end
  
  template "/home/splunkadmin/opt/splunk/etc/apps/Splunk_TA_vmware/local/engine.template" do
    source "forwarder/engine.template.erb"
    owner "splunkadmin"
    group "splunkadmin"
    variables(
      :vsphere_user => vsphere_user,
      :vsphere_user_pass => vsphere_user_pass,
      :esxhost_user => esxhost_user,
      :esxhost_user_pass => esxhost_user_pass,
      :vc_host=> vc_host
    )
  end
  
  #Create the config files
  execute "splunk_config_generator" do
    user "splunkadmin"
    group "splunkadmin"
    cwd "/home/splunkadmin/opt/splunk/etc/apps/Splunk_TA_vmware/local"
    command "PATH=$PATH:/home/splunkadmin/opt/splunk/etc/apps/Splunk_TA_vmware/bin /home/splunkadmin/opt/splunk/etc/apps/Splunk_TA_vmware/bin/enginebuilder.py"
    notifies :start, "service[splunk]", :immediately
  end
end

service "splunk" do
  action :start
end
