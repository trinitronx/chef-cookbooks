#
# Cookbook Name:: bacula
# Recipe:: client
#
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

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

node.set_unless['bacula']['client']['password'] = secure_password

bacula_servers = []
search(:node, "roles:#{node['bacula']['directorrole']}") do |n|
  bacula_servers << n.name
end
bacula_servers = bacula_servers.uniq

# Load chef-vault if encrypted backups are enabled
encrypted_backups = false
if node['bacula']
  if node['bacula']['client']
    if node['bacula']['client']['encrypt_backups']
      include_recipe 'chef-vault'
      encrypted_backups = true
      bacula_client_pki_keypair = chef_vault_item('bacula_pki', "clientkeypair-#{node['fqdn']}")
    end
  end
end

# TODO - setup encryption key distribution
case node["platform"]
when "debian", "ubuntu"
  package "bacula-fd"
  service "bacula-fd" do
    supports :start => true, :stop => true, :restart => true
  end
  template "/etc/bacula/bacula-fd.conf" do
#    source "bacula-fd.conf.erb"
    variables ({
      :bacula_servers => bacula_servers
    })
    notifies :restart, resources(:service => "bacula-fd")
  end
when "windows"
  # Install the client app
  windows_package node['bacula']['client']['win_displayname'] do
    if node['kernel']['machine'] == "x86_64"
      source node['bacula']['client']['win_url']
      checksum node['bacula']['client']['win_checksum']
    else
      source node['bacula']['client']['win_url_32bit']
      checksum node['bacula']['client']['win_checksum_32bit']
    end
    action :install
    options "/S"
    installer_type :custom
  end
  service "Bacula-fd" do
    action :nothing
    supports :start => true, :stop => true, :restart => true
  end
  template "c:/program files/bacula/bacula-fd.conf" do
    source "bacula-fd.conf.erb"
    variables :bacula_servers => bacula_servers
    notifies :restart, resources(:service => "Bacula-fd")
  end
  # Setup additional backup scripts
  directory "c:/program files/bacula/scripts"
  # Sql server backup scripts
  if node['bacula']['client']['scripts']['sqlserver2000backup']['stagingdirectory']
    directory node['bacula']['client']['scripts']['sqlserver2000backup']['stagingdirectory']
    template "c:/program files/bacula/scripts/sqlserver2000backup.sql"
  end
end
