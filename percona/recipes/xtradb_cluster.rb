#
# Cookbook Name:: percona
# Recipe:: xtradb-cluster
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

# Set up the Percona apt repository
include_recipe "percona::repository"

# Search for cluster masters (writable nodes) and slaves (used for failover only)
cluster_masters = search("node", "percona_cluster_role:master AND chef_environment:#{node.chef_environment}") || []
master_count = cluster_masters.length
cluster_slaves = search("node", "percona_cluster_role:slave AND chef_environment:#{node.chef_environment}") || []
cluster_members = cluster_masters.concat(cluster_slaves)

# Reduce the cluster_members down to just the IPs
cluster_members.map! do |member|
	server_ip = begin
		member['ipaddress']
	end
end

# Reject this node and empty values from the list
cluster_members.reject! do |member|
	member == node['ipaddress'] || member == nil
end

# Determine if the cluster needs to be bootstrapped
bootstrap_cluster = false
bootstrap_cluster = cluster_members.length == 0

# Construct the cluster address
wsrep_cluster_address = 'gcomm://'

# Add members to the list if the cluster is already bootstrapped
if bootstrap_cluster == false
	wsrep_cluster_address += cluster_members.join(',')
end

# Prestage the mysql configuration files
directory node['mysql']['conf_dir'] do
  owner "root"
  group "root"
  mode 00755
  action :create
end

directory node['mysql']['confd_dir'] do
  owner "root"
  group "root"
  mode 00755
  action :create
end

template "#{node['mysql']['conf_dir']}/my.cnf" do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode 00644
end

template "#{node['mysql']['conf_dir']}/debian.cnf" do
  source "debian.cnf.erb"
  owner "root"
  group "root"
  mode 00600
end

template "#{node['mysql']['confd_dir']}/xtradb_cluster.cnf" do
  source "xtradb_cluster.cnf.erb"
  owner "root"
  group "root"
  mode 00644
  variables(
    :wsrep_cluster_address => wsrep_cluster_address,
    :master_count => master_count
  )
end

# Prepare a debconf seed for the percona-server package
execute "install percona preseed" do
	action  :nothing
	command "debconf-set-selections /tmp/percona.preseed"
end

template "/tmp/percona.preseed" do
	source   "percona-server.preseed.erb"
	mode     0600
	action   :create
	variables(
		:root_password => node['percona']['root_password']
	)
	notifies :run, resources(:execute => "install percona preseed"), :immediately
end

# Install the Percona packages
package "percona-xtrabackup" do
  action :install
  only_if { node['percona']['sst_method'] == "xtrabackup" }
end
package "percona-xtradb-cluster-client-5.5"
package "percona-xtradb-cluster-server-5.5"

# Install mysql ruby gem after dependencies are met
node.set['build_essential']['compiletime'] = true
include_recipe "build-essential"
chef_gem "mysql" do
  action :nothing
end
package "libmysqlclient-dev" do
  action :install
  notifies :install, "chef_gem[mysql]", :immediately
end

# Get MySQL authentication info
mysql_connection_info = { :host => "localhost", :username => 'root', :password => node['percona']['root_password'] }

# Update the password for the debian_sys_maint user
mysql_database_user "debian-sys-maint" do
  connection mysql_connection_info
  host 'localhost'
  password node['percona']['debian_sys_maint_password']
  privileges [:all]
  action :grant
end

# Set up the xtrabackup user
if node['percona']['sst_method'] == "xtrabackup"
  mysql_database_user node['percona']['sst_user'] do
    connection mysql_connection_info
    host 'localhost'
    password node['percona']['sst_password']
    privileges ["reload","lock tables","replication client"]
    action :grant
  end
end

# Set up the clustercheck script
include_recipe "percona::clustercheck"