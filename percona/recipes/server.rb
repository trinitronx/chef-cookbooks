#
# Cookbook Name:: percona
# Recipe:: server
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
node.override['mysql']['client']['packages'] = node['percona']['server_client_packages']

# Prestage the my.cnf configuration file
directory node['mysql']['conf_dir'] do
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

# Retrieve root password from the data bag containing MySQL user configuration
encryption_key = Chef::EncryptedDataBagItem.load_secret(node['percona']['databag_encryption_key'])
root = Chef::EncryptedDataBagItem.load(node['percona']['users_databag'], "root", encryption_key)

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

# Install Percona Server package
package node['percona']['server_package']