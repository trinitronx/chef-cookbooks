#
# Cookbook Name:: nagios
# Recipe:: client_windows
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
include_recipe "windows"

if node['platform'] == "windows" then
  # determine hosts that NRPE will allow monitoring from
  mon_host = ['127.0.0.1']

  # put all nagios servers that you find in the NPRE config.
  if node['nagios']['multi_environment_monitoring']
    search(:node, "role:#{node['nagios']['server_role']}") do |n|
      mon_host << n['ipaddress']
    end
  else
    search(:node, "role:#{node['nagios']['server_role']} AND chef_environment:#{node.chef_environment}") do |n|
      mon_host << n['ipaddress']
    end
  end
  # on the first run, search isn't available, so if you're the nagios server, go
  # ahead and put your own IP address in the NRPE config (unless it's already there).
  if node.run_list.roles.include?(node['nagios']['server_role'])
    unless mon_host.include?(node['ipaddress'])
      mon_host << node['ipaddress']
    end
  end

  arch = node['kernel']['machine'] == "x86_64" ? "x64" : "Win32"

  # Download and install NSClient++
  windows_package "NSClient++ (#{arch})" do
    source "http://chefpantry.prod.biola.edu/chef_files/nagios/NSCP-0.4.1.90-#{arch}.msi"
    options "/quiet /norestart" 
    action :install
  end

  service "nscp" do
    action :nothing
    supports :restart => true
  end

  # Create configuration file
  template "C:/Program Files/NSClient++/nsclient.ini" do
    source "nsclient.ini.erb"
    variables(
      :mon_host => mon_host,
      :aliases => node["nagios"]["aliases"]
    )
    notifies :restart, resources(:service => "nscp")
  end
end