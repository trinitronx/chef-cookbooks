#
# Cookbook Name:: bacula
# Recipe:: director
#
# Copyright 2012, computerlyrik
# Copyright 2014, Biola University 
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

include_recipe "mysql::server"
include_recipe "database::mysql"
mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

node.set_unless['bacula']['mysql_password'] = secure_password

mysql_database_user node['bacula']['mysql_user'] do
  password  node['bacula']['mysql_password']
  database_name node['bacula']['mysql_user']
  connection mysql_connection_info
#  notifies :run, resources(:execute=>"create_mysql_tables")
  action [:create,:grant]
end

mysql_database node['bacula']['mysql_user'] do
  connection mysql_connection_info
  action :create
end

execute "create_mysql_tables" do
  command "mysql -u root -p#{node['mysql']['server_root_password']} #{node['bacula']['mysql_user']} < /usr/share/dbconfig-common/data/bacula-director-mysql/install/mysql"
  action :nothing
  subscribes :run, resources(:mysql_database => node['bacula']['mysql_user'])
end

################### Install and configure bacula

# First install the bacula client, so it can be safely assumed to be present for the default restore job
include_recipe 'bacula::client'

package "bacula-director-mysql"
package "bacula-console"
service "bacula-director"

package "lsscsi" # For device identification

node.set_unless['bacula']['dir']['password'] = secure_password
node.set_unless['bacula']['dir']['password_monitor'] = secure_password

service "bacula-director" do
  action :nothing
  supports :status => true, :restart => true, :reload => true
end


# Setup the client configurations
bacula_client_configs = []
bacula_client_search = search(:node, "roles:#{node['bacula']['clientrole']} OR roles:#{node['bacula']['directorrole']}")
bacula_client_search.each do |nodeobj|
  # Ensure client recipe run has completed and password is present
  if nodeobj['bacula']
    if nodeobj['bacula']['client']
      if nodeobj['bacula']['client']['password']
        hashtoadd = {}
        hashtoadd[nodeobj.name] = {}
        hashtoadd[nodeobj.name]['ip'] = nodeobj['ipaddress']
        hashtoadd[nodeobj.name]['password'] = nodeobj['bacula']['client']['password']
        if nodeobj['bacula']['client']['filesets']
          hashtoadd[nodeobj.name]['filesets'] = nodeobj['bacula']['client']['filesets']
          # Storing platform_family for case senstivity options
          hashtoadd[nodeobj.name]['platform_family'] = nodeobj['platform_family']
        end
        if nodeobj['bacula']['client']['schedules']
          hashtoadd[nodeobj.name]['schedules'] = nodeobj['bacula']['client']['schedules']
        end
        if nodeobj['bacula']['client']['jobs']
          hashtoadd[nodeobj.name]['jobs'] = nodeobj['bacula']['client']['jobs']
        end
        if nodeobj['bacula']['client']['options']
          hashtoadd[nodeobj.name]['options'] = nodeobj['bacula']['client']['options']
        end
        bacula_client_configs << hashtoadd
      end
    end
  end
end

require 'resolv'
bacula_nonchef_clients = []
data_bag("backup_targets_nonchef").each do |target|
  if data_bag_item('backup_targets_nonchef', target)['bacula_filesets']
    databhostname = data_bag_item('backup_targets_nonchef', target)['hostname']
    bacula_nonchef_clients << databhostname
    hashtoadd = {}
    hashtoadd[databhostname] = {}
    hashtoadd[databhostname]['ip'] = data_bag_item('backup_targets_nonchef', target)['ip'] || Resolv.getaddress(databhostname)
    hashtoadd[databhostname]['password'] = data_bag_item('backup_targets_nonchef', target)['password']
    hashtoadd[databhostname]['filesets'] = data_bag_item('backup_targets_nonchef', target)['bacula_filesets']
    # Storing platform_family for case senstivity options
    hashtoadd[databhostname]['platform_family'] = data_bag_item('backup_targets_nonchef', target)['platform_family']
    if data_bag_item('backup_targets_nonchef', target)['schedules']
      hashtoadd[databhostname]['schedules'] = data_bag_item('backup_targets_nonchef', target)['schedules']
    end
    if data_bag_item('backup_targets_nonchef', target)['jobs']
      hashtoadd[databhostname]['jobs'] = data_bag_item('backup_targets_nonchef', target)['jobs']
    end
    if data_bag_item('backup_targets_nonchef', target)['options']
      hashtoadd[databhostname]['options'] = data_bag_item('backup_targets_nonchef', target)['options']
    end
    bacula_client_configs << hashtoadd
  end
end

bacula_client_configs = bacula_client_configs.sort_by{|host| host.first}

# Find storage daemons & their devices
storage_daemons = []
bacula_storage_search = search(:node, "roles:#{node['bacula']['storagerole']}")
bacula_storage_search.each do |nodeobj|
  if nodeobj['bacula']
    if nodeobj['bacula']['sd']
      hashtoadd = {}
      hashtoadd[nodeobj.name] = {}
      hashtoadd[nodeobj.name]['ipaddress'] = nodeobj['ipaddress']
      hashtoadd[nodeobj.name]['password'] = nodeobj['bacula']['sd']['password']
      hashtoadd[nodeobj.name]['devices'] = []
      nodeobj['bacula']['sd']['devices'].each do |sddevice|
        unless sddevice.first[1]['Autochanger']
          hashtoadd[nodeobj.name]['devices'] << sddevice
        end
      end
      if nodeobj['bacula']['sd']['autochangers']
        nodeobj['bacula']['sd']['autochangers'].each do |acdevice|
          # Need to create a new storage resource for each media type
          # Cross-reference every autochanger device against the corresponding device entry
          # 
          # these are the most hateable variable names I could devise
          acdevice.first[1]['Devices'].each do |acdevicedevice|
            # Looping again through the storage devices for the cross-reference
            nodeobj['bacula']['sd']['devices'].each do |sddevice|
              if sddevice.first[0] == acdevicedevice
                achashtoadd = {}
                achashtoadd[acdevice.first[0]] = {}
                achashtoadd[acdevice.first[0]]['Media Type'] = sddevice.first[1]['Media Type']
                achashtoadd[acdevice.first[0]]['Autochanger'] = 'yes'
                hashtoadd[nodeobj.name]['devices'] << achashtoadd
              end
            end
          end
        end
      end
      storage_daemons << hashtoadd
    end
  end
end

template "/etc/bacula/bacula-dir.conf" do
  group node['bacula']['group']
  mode 0640
  variables({
    :bacula_clients => bacula_client_configs,
    :bacula_storage => storage_daemons
  })
  notifies :reload, "service[bacula-director]"
end

template "/etc/bacula/bconsole.conf"
