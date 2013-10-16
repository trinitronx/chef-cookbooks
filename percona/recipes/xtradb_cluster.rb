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

# Use Percona-provided client packages for the mysql ruby gem dependencies
node.override['mysql']['client']['packages'] = node['percona']['xtradb_cluster_client_packages']

# Install the ruby gem
include_recipe "mysql::ruby"

# Search for cluster masters (writable nodes) and slaves (used for failover only)
cluster_masters = search("node", "percona_cluster_role:master AND chef_environment:#{node.chef_environment}") || []
master_count = cluster_masters.length
cluster_slaves = search("node", "percona_cluster_role:slave AND chef_environment:#{node.chef_environment}") || []

# Sort by hostname to provide stable ordering
cluster_masters.sort! { |a, b| a['hostname'] <=> b['hostname'] }
cluster_slaves.sort! { |a, b| a['hostname'] <=> b['hostname'] }

# Reduce the cluster_members down to just the IPs
cluster_members = cluster_masters.concat(cluster_slaves)
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

# Retrieve user information from the data bag containing MySQL user configuration
encryption_key = Chef::EncryptedDataBagItem.load_secret(node['percona']['databag_encryption_key'])
root = Chef::EncryptedDataBagItem.load(node['percona']['users_databag'], "root", encryption_key)
debian_sys_maint = Chef::EncryptedDataBagItem.load(node['percona']['users_databag'], "debian-sys-maint", encryption_key)
sst_user = Chef::EncryptedDataBagItem.load(node['percona']['users_databag'], node['percona']['sst_user'], encryption_key)

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
  variables(
    :dsm_password => debian_sys_maint['password']
  )
end

template "#{node['mysql']['confd_dir']}/xtradb_cluster.cnf" do
  source "xtradb_cluster.cnf.erb"
  owner "root"
  group "root"
  mode 00644
  variables(
    :wsrep_cluster_address => wsrep_cluster_address,
    :master_count => master_count,
    :sst_password => sst_user['password']
  )
end

# Prepare a debconf seed for the percona-server package
execute "install percona preseed" do
  action  :nothing
  command "debconf-set-selections /var/cache/local/preseeding/percona.seed"
end

template "/var/cache/local/preseeding/percona.seed" do
  source   "percona-server.seed.erb"
  mode     0600
  action   :create
  variables(
    :root_password => root['password']
  )
  notifies :run, resources(:execute => "install percona preseed"), :immediately
end

# Install the Percona XtraDB Cluster server package
package node['percona']['xtradb_cluster_package']

# Get MySQL authentication info
mysql_connection_info = { :host => "localhost", :username => 'root', :password => root['password'] }

# Update the password for the debian_sys_maint user
mysql_database_user "debian-sys-maint" do
  connection mysql_connection_info
  host 'localhost'
  password debian_sys_maint['password']
  privileges [:all]
  action :grant
end

# Set up the xtrabackup user
if node['percona']['sst_method'] == "xtrabackup"
  mysql_database_user node['percona']['sst_user'] do
    connection mysql_connection_info
    host 'localhost'
    password sst_user['password']
    privileges ["reload","lock tables","replication client"]
    action :grant
  end
end

# Set up the clustercheck script
include_recipe "percona::clustercheck"