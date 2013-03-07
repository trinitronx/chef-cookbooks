#
# Cookbook Name:: vsftpd
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

# Install vsftpd
package "vsftpd" do
  action :install
end

# Set up the vsftpd service
service "vsftpd" do
  supports :start => true, :restart => true, :stop => true
  action [ :enable, :start ]
end

# Collect a list of users that are allowed to log in
users = []

# Search for all items in the 'users' data bag that match a given group and loop over them
search(:users, "groups:#{node['vsftpd']['userlist_group']}") do |user|
  # Add the ID to the list of users
  users << user["id"]
end

# Set up a list of users allowed to log in
template node['vsftpd']['userlist_file'] do
  source "vsftpd.user_list.erb"
  owner "root"
  group "root"
  mode 0644
  variables(:users => users)
end

# Set up the configuration file
template node['vsftpd']['conf_file'] do
  source "vsftpd.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :anonymous_enable => node['vsftpd']['anonymous_enable'],
    :local_enable => node['vsftpd']['local_enable'],
    :write_enable => node['vsftpd']['write_enable'],
    :local_umask => node['vsftpd']['local_umask'],
    :userlist_file => node['vsftpd']['userlist_file']
  )
  notifies :restart, resources(:service => "vsftpd")
end