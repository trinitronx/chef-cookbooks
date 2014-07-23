#
# Cookbook Name:: opsview
# Recipe:: client
#
# Copyright 2014, Biola University
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

# Determine the hosts that the agent will allow monitoring from
monitoring_hosts = ['127.0.0.1']
search(:node, "role:#{node['opsview']['server_role']}") do |n|
  monitoring_hosts << n['ipaddress']
end
monitoring_hosts.concat node['opsview']['allowed_hosts'] if node['opsview']['allowed_hosts']

# Don't install the agent on the Opsview server
unless node.run_list.include?("role[#{node['opsview']['server_role']}]")
  # Install the agent
  case node['platform']
  when "ubuntu"
    include_recipe "opsview::apt_repository"
    package "opsview-agent"
  when "redhat", "centos"
    include_recipe "opsview::yum_repository"
    package "opsview-agent"
  when "windows"
    arch = node['kernel']['machine'] == "x86_64" ? "x64" : "Win32"
    windows_package "Opsview NSClient++ Windows Agent (#{arch})" do
      source node["opsview"]["windows_agent_#{arch}_url"]
      options "/quiet /norestart" 
      action :install
    end
  end
end

# Configure the agent
if node['platform'] == "ubuntu" || node['platform'] == "redhat" || node['platform'] == "centos"
  # Make sure the nagios user has a valid shell
  user "nagios" do
    shell "/bin/bash"
    action :modify
  end

  service "opsview-agent" do
    action :nothing
    if node['platform'] == "ubuntu" 
      supports :restart => true
    end
  end

  directory node["opsview"]["agent_conf_dir"] do
    owner "nagios"
    group "nagios"
    mode 00755
    recursive true
  end

  template "#{node["opsview"]["agent_conf_dir"]}/override.cfg" do
    source 'override.cfg.erb'
    owner "nagios"
    group "nagios"
    mode 00644
    variables(
      :monitoring_hosts => monitoring_hosts,
      :commands => node["opsview"]["commands"]
    )
    notifies :restart, resources(:service => "opsview-agent")
  end

  # Add any custom NRPE plugins
  remote_directory node['opsview']['plugin_dir'] do
    source "client_plugins"
    files_owner "root"
    files_group "root"
    files_mode 00755
  end
else
  # Add any custom external scripts
  remote_directory "#{node["opsview"]["agent_conf_dir"]}/scripts" do
    source "nsc_scripts"
  end

  service "NSClientpp" do
    action :nothing
    supports :restart => true
  end

  # Create configuration file
  template "#{node["opsview"]["agent_conf_dir"]}/opsview.ini" do
    source "opsview.ini.erb"
    variables(
      :monitoring_hosts => monitoring_hosts,
      :aliases => node["opsview"]["aliases"],
      :scripts => node["opsview"]["scripts"],
      :wrapped_scripts => node["opsview"]["wrapped_scripts"]
    )
    notifies :restart, resources(:service => "NSClientpp")
  end
end