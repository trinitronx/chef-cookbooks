#
# Cookbook Name:: splunk_windows
# Recipe:: default
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


splunk_cmd = "#{node['splunk']['forwarder_home']}/bin/splunk.exe"
splunk_package_version = "splunkforwarder-#{node['splunk']['forwarder_version']}-#{node['splunk']['forwarder_build']}"

splunk_file = splunk_package_version + 
  if node['kernel']['machine'] == "x86_64"
      "-x64-release.msi"
    else
      "-x86-release.msi"
    end
 

windows_package "Universal Forwarder" do
  source "#{node['splunk']['forwarder_root']}/#{node['splunk']['forwarder_version']}/universalforwarder/windows/#{splunk_file}"
  options node['splunk']['forwarder_install_opts'] + " RECEIVING_INDEXER=\"" + node[:splunk][:indexer_name] + ":" + node[:splunk][:receiver_port] + "\" /quiet" 
  action :install
end

unless File.exists?("c:/chef/splunk_setup_passwd")
  splunk_password = node['splunk']['auth'].split(':')[1]
  execute "\"#{splunk_cmd}\" edit user admin -password #{splunk_password} -roles admin -auth admin:changeme"
  execute "echo true > c:/chef/splunk_setup_passwd"
end



