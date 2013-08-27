#
# Cookbook Name:: percona
# Recipe:: clustercheck
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

# Install xinetd
package "xinetd"

# Retrieve authentication information from the mysql_users data bag
root = data_bag_item("mysql_users", "root")
clustercheck = data_bag_item("mysql_users", "clustercheck")

# Install the clustercheck script
template "/usr/bin/clustercheck" do
  source   "clustercheck.erb"
  mode     0755
  action   :create
  variables(
    :clustercheck_password => clustercheck['password']
  )
end

# Create mysqlchk entry in /etc/services
execute "create mysqlchk service" do
  command %Q(echo "mysqlchk        9200/tcp                        # mysqlchk" >> /etc/services)
  not_if "grep 9200/tcp /etc/services"
end

# Set up the clustercheck user
mysql_connection_info = { :host => "localhost", :username => 'root', :password => root['password'] }
mysql_database_user 'clustercheck' do
  connection mysql_connection_info
  host 'localhost'
  password clustercheck['password']
  privileges [:process]
  action :grant
end