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

# Prepare a debconf seed for the percona-server package
execute "install percona preseed" do
  action  :nothing
  command "debconf-set-selections /tmp/percona.preseed"
end

# Retrieve root password from the mysql_users data bag
root = data_bag_item("mysql_users", "root")

template "/tmp/percona.preseed" do
  source   "percona-server.preseed.erb"
  mode     0600
  action   :create
  variables(
    :root_password => root['password']
  )
  notifies :run, resources(:execute => "install percona preseed"), :immediately
end

# Install Percona Server
package node['percona']['server_package']