#
# Cookbook Name:: elasticsearch
# Recipe:: default
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

# Install the Java 7 JDK
include_recipe "java::default"

# Set up the elasticsearch repository
include_recipe "elasticsearch::repository"

# Install the elasticsearch package
package "elasticsearch"

# Increase open file and memory limits for the elasticsearch user
execute "set user limits" do
  command "sed -i 's/# session    required   pam_limits.so/session    required   pam_limits.so/' /etc/pam.d/su"
  action :run
  not_if { ::File.read("/etc/pam.d/su").match(/^session    required   pam_limits\.so/) }
end

template "/etc/security/limits.d/elasticsearch.conf" do
  source "elasticsearch-limits.conf.erb"
  mode 0644
end

# Search for master nodes in the cluster
master_nodes = search("node", "elasticsearch_master_node:true AND chef_environment:#{node.chef_environment}") || []
# Sort by hostname to provide stable ordering
master_nodes.sort! { |a, b| a['fqdn'] <=> b['fqdn'] }

# Reduce the master nodes down to just the FQDNs
master_nodes.map! do |member|
  server_fqdn = begin
    member['fqdn']
  end
end

# Reject this node and empty values from the list
master_nodes.reject! do |member|
  member == node['fqdn'] || member == nil
end

# Set up the elasticsearch config
template "/etc/elasticsearch/elasticsearch.yml" do
  source "elasticsearch.yml.erb"
  mode 0644
  variables(
    :master_nodes => master_nodes
  )
  notifies :restart, "service[elasticsearch]"
end

# Start the service
service "elasticsearch" do
  priority 90
  supports :restart => true
  action [:enable, :start]
end