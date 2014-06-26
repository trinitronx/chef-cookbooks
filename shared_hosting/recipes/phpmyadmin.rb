#
# Cookbook Name:: shared_hosting
# Recipe:: phpmyadmin
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

# Install nginx and PHP
include_recipe "shared_hosting::nginx"
include_recipe "shared_hosting::php"

# Install phpmyadmin
package "phpmyadmin"

service "php5-fpm" do
  supports :restart => true, :reload => true
  action :nothing
end

# Create a new php-fpm pool configuration for phpmyadmin
template "/etc/php5/fpm/pool.d/phpmyadmin.conf" do
  owner "root"
  group "root"
  mode 00644
  source "php-fpm-pool.conf.erb"
  variables(
    :site_name => "phpmyadmin",
    :user_name => "www-data",
    :socket_dir => node['shared_hosting']['php']['socket_dir'],
    :php_restrict_basedir => false,
    :php_admin_flags => {"suhosin.simulation" => "On"}
  )
  notifies :restart, "service[php5-fpm]"
end

# Retrieve encryption key for databag items
encryption_key = Chef::EncryptedDataBagItem.load_secret(node['mysql']['management']['databag_encryption_key'])
pma_user = Chef::EncryptedDataBagItem.load(node['mysql']['management']['users_databag'], 'phpmyadmin', encryption_key)
root_user = Chef::EncryptedDataBagItem.load(node['mysql']['management']['users_databag'], 'root', encryption_key)

# Replace the phpmyadmin database config file
template "/etc/phpmyadmin/config-db.php" do
  owner "root"
  group "www-data"
  mode 00640
  source "config-db.php.erb"
  variables(
    :dbpass => pma_user['password']
  )
end

# Create the tables for phpmyadmin
execute "Create tables" do
  command "gunzip /usr/share/doc/phpmyadmin/examples/create_tables.sql.gz; mysql -uroot -p#{root_user['password']} < /usr/share/doc/phpmyadmin/examples/create_tables.sql"
  creates "/usr/share/doc/phpmyadmin/examples/create_tables.sql"
  action :run
end