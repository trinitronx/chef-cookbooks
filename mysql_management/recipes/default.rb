#
# Cookbook Name:: mysql_management
# Recipe:: default
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

# Install mysql ruby gem
include_recipe "mysql::ruby"

# Retrieve authentication information from the data bag containing MySQL user configuration
encryption_key = Chef::EncryptedDataBagItem.load_secret(node['mysql']['management']['databag_encryption_key'])
root = Chef::EncryptedDataBagItem.load(node['mysql']['management']['users_databag'], "root", encryption_key)

# Create a hash of MySQL authentication info
mysql_connection_info = { :host => "localhost", :username => 'root', :password => root['password'] }

 # Loop through all of the items in the data bag containing MySQL database configuration
mysql_databases = data_bag(node['mysql']['management']['databases_databag'])
mysql_databases.each do |db_name|
	database = Chef::EncryptedDataBagItem.load(node['mysql']['management']['databases_databag'], db_name, encryption_key)
  # Create the database if it doesn't exist
	mysql_database db_name do
		connection mysql_connection_info
		action :create
	end

	# Create any dbo users if defined
	if database['dbo_users']
		database['dbo_users'].each do |username, values|
			values['privileges'] ||= ["all"]
			mysql_database_user username do
				connection mysql_connection_info
				host values['host']
				database_name db_name
				password values['password']
				privileges values['privileges']
				action :grant
			end
		end
	end
end

# Loop through all of the items in the data bag containing MySQL user configuration
mysql_users = data_bag(node['mysql']['management']['users_databag'])
mysql_users.each do |user_name|
	user = Chef::EncryptedDataBagItem.load(node['mysql']['management']['users_databag'], user_name, encryption_key)
	# Grant permissions on each of the databases configured
	if user['privileges']
		user['privileges'].each do |db_name, db_privileges|
			mysql_database_user user_name do
				connection mysql_connection_info
				host user['host']
				database_name db_name
				password user['password']
				privileges db_privileges
				action :grant
			end
		end
	end
end