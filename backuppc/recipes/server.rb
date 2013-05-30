#
# Cookbook Name:: backuppc
# Recipe:: server 
#
# Copyright 2013, Biola University
# Copyright 2009, 37signals
# Copyright 2009-2011, Opscode, Inc
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

# Install backuppc
package "backuppc" do
  action :install
end

include_recipe "apache2"

if node['backuppc']['enable_ssl']
  include_recipe "apache2::mod_ssl"
end

apache_site "000-default" do
  enable false
end

template "#{node['apache']['dir']}/sites-available/backuppc" do
  source "backuppc.apachesite.erb"
  mode 00644
  #variables( :public_domain => public_domain,
  #    :backuppc_url => node['backuppc']['url']
  #    )
  if ::File.symlink?("#{node['apache']['dir']}/sites-enabled/backuppc")
    notifies :reload, "service[apache2]"
  end
end

apache_site "backuppc"

# Generate htpasswd file
group = node['backuppc']['users_databag_group']
begin
  sysadmins = search(:users, "groups:#{group}")
rescue Net::HTTPServerException
  Chef::Log.fatal("Could not find appropriate items in the \"users\" databag.  Check to make sure there is a users databag and if you have set the \"users_databag_group\" that users in that group exist")
  raise 'Could not find appropriate items in the "users" databag.  Check to make sure there is a users databag and if you have set the "users_databag_group" that users in that group exist'
end

template "/etc/backuppc/htpasswd" do
  source "htpasswd.users.erb"
  #owner node['backupc']['user']
  #mode 00640
  variables(:sysadmins => sysadmins)
end

service "backuppc" do
  supports :restart => true, :reload => true, :start => true, :stop => true
  action [ :enable ]
end


template "/etc/backuppc/config.pl" do
  source "config.pl.erb"
  notifies :reload, "service[backuppc]"
end

# Populate the list of hosts in Chef to backup
#
# node_target_counts is used in the host config
# template generation (cheap way of making lists
# that don't have a comma on their last entry)
chef_nodes = []
node_target_counts = {}
search(:node, "backups_targets:*").each do |n|
  targetcount = 0
  n['backups']['targets'].each_with_index do |params, index|
    params.each_key do |backup_target|
      if (params[backup_target]['backupservice'].nil?) or (params[backup_target]['backupservice'] == "backuppc")
        chef_nodes << n unless chef_nodes.include? n
        targetcount = targetcount + 1
      end
    end
  end
  node_target_counts[n.name] = targetcount
end
#chef_nodes.sort!

# Look for non-chef hosts to backup
nonchef_nodes_presort = []
search(:backup_targets_nonchef, "id:*").each do |datab|
  datab['backups']['targets'].each_with_index do |params, index|
    params.each_key do |backup_target|
      if (params[backup_target]['backupservice'].nil?) or (params[backup_target]['backupservice'] == "backuppc")
        unless nonchef_nodes_presort.include? datab['hostname']
          newhost = Hash.new
          newhost[datab['hostname']] = Hash.new
          newhost[datab['hostname']]['hostname'] = datab['hostname']
          newhost[datab['hostname']]['backups'] = datab['backups']
          newhost[datab['hostname']]['backup_target_count'] = 1
          nonchef_nodes_presort << newhost
        else
          nonchef_nodes_presort[datab['hostname']]['backup_target_count'] += 1
        end 
      end
    end
  end
end

# Ugly sorting process here; need to refactor
# Generates nonchef_nodes via sort on the keys in nonchef_nodes_presort
# (Implemented because "nonchef_nodes_presort.sort {|a,b| a[:zip] <=> b[:zip]}"
# and similar weren't working)
nonchef_nodes_names = []
nonchef_nodes = []
nonchef_nodes_presort.each do |n| 
  nonchef_nodes_names << n.keys[0]
end
nonchef_nodes_names_sorted = nonchef_nodes_names.sort
nonchef_nodes_names_sorted.each do |n|
  nonchef_nodes << nonchef_nodes_presort[nonchef_nodes_names.index(n)]
end
# End terrible sort

# Set up the backuppc hosts file
template "/etc/backuppc/hosts" do
  source "hosts.erb"
  variables(
    :chef_nodes => chef_nodes,
    :nonchef_nodes => nonchef_nodes
  )
  notifies :reload, "service[backuppc]"
end


# Set up config files for each Chef node
chef_nodes.each do |n|
  template "/etc/backuppc/" + n.name + ".pl" do
    source "hostconfig.pl.erb"
    owner "backuppc"
    group "www-data"
    mode 0640
    variables(
      :nodehash => n,
      :node_target_counts => node_target_counts
    )
    notifies :reload, "service[backuppc]"
  end
end


# Set up config files for each non-Chef node
nonchef_nodes.each do |n|
  n.each do |nkey, nvalue|
    template "/etc/backuppc/" + nvalue['hostname'].to_s + ".pl" do
      source "hostconfig_nonchef.pl.erb"
      owner "backuppc"
      group "www-data"
      mode 0640
      variables(
        :nodehash => nvalue
      )
      notifies :reload, "service[backuppc]"
    end
  end
end


service "backuppc" do
  action [ :start ]
end
