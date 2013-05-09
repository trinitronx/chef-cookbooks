#
# Cookbook Name:: nagios
# Recipe:: server_extras
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

service "nagios" do
  service_name node['nagios']['server']['service_name']
  action [ :nothing ]
  supports :status => true, :restart => true, :reload => true
end

# Install the "exfoliation" Nagios theme (now the default for Nagios Core)
remote_directory "#{node['nagios']['conf_dir']}/stylesheets" do
  source "exfoliation/stylesheets"
end

remote_directory "#{node['nagios']['docroot']}/images" do
  source "exfoliation/images"
end

# Install custom logos
remote_directory "#{node['nagios']['docroot']}/images/logos" do
  source "logos"
end

# Add each monitored node to the hostextinfo.cfg template
Chef::Log.info("Beginning search for nodes.  This may take some time depending on your node count")
nodes = Array.new

if node['nagios']['multi_environment_monitoring']
  if node["nagios"].attribute?("environments")
    nodes = search(:node, "hostname:[* TO *] AND (chef_environment:#{node['nagios']['environments'].join(" OR chef_environment:")})")
  else
    nodes = search(:node, "hostname:[* TO *]")
  end
else
  nodes = search(:node, "hostname:[* TO *] AND chef_environment:#{node.chef_environment}")
end

# Sort by name to provide stable ordering
nodes.sort! {|a,b| a.name <=> b.name }

template "#{node['nagios']['config_dir']}/hostextinfo.cfg" do
  source "hostextinfo.cfg.erb"
  owner "nagios"
  group "nagios"
  mode 0644
  variables(
    :hosts => nodes
  )
  notifies :reload, resources(:service => "nagios")
end