#
# Cookbook Name:: percona
# Recipe:: haproxy
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

# Install and enable HAProxy
package "haproxy" do
  action :install
  notifies :run, "execute[enable haproxy]", :immediately
end

execute "enable haproxy" do
 command "sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/haproxy"
 action :nothing
end

# Search for cluster members
cluster_masters = search("node", "percona_cluster_role:master AND chef_environment:#{node.chef_environment}") || []
cluster_slaves = search("node", "percona_cluster_role:slave AND chef_environment:#{node.chef_environment}") || []

# Load the configuration from a template
template "/etc/haproxy/haproxy.cfg" do
  source "haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 00644
  variables(
    :cluster_masters => cluster_masters,
    :cluster_slaves => cluster_slaves    
  )
  notifies :restart, "service[haproxy]"
end

service "haproxy" do
  action :nothing
end