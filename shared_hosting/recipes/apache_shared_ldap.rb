#
# Cookbook Name:: shared_hosting
# Recipe:: apache_shared_ldap
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

# Install the Net::LDAP gem
chef_gem "net-ldap"
require 'net/ldap'

# Install apache2 and PBIS Open
include_recipe 'chef-vault'
include_recipe "shared_hosting::default"
include_recipe "shared_hosting::apache2"
include_recipe "pbis-open::default"

# Service definitions
service "apache2" do
  supports :restart => true, :reload => true
  action :nothing
end

# Create a directory and index for the shared Apache site
directory "#{node['shared_hosting']['apache2']['sites_dir']}/#{node['shared_hosting']['apache_shared_ldap']['server_name']}" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

cookbook_file "#{node['shared_hosting']['apache2']['sites_dir']}/#{node['shared_hosting']['apache_shared_ldap']['server_name']}/index.html" do
  source "404.html"
  owner "root"
  group "root"
  mode 00644
  action :create
end

# Create the shared site configurations
template "#{node['apache']['dir']}/sites-available/#{node['shared_hosting']['apache_shared_ldap']['server_name']}" do
  owner "root"
  group "root"
  mode 00644
  source node['shared_hosting']['apache_shared_ldap']['site_template']
  variables(
    :server_name => node['shared_hosting']['apache_shared_ldap']['server_name'],
    :document_root => "#{node['shared_hosting']['apache2']['sites_dir']}/#{node['shared_hosting']['apache_shared_ldap']['server_name']}"
  )
  notifies :reload, "service[apache2]"
end

template "#{node['apache']['dir']}/sites-available/#{node['shared_hosting']['apache_shared_ldap']['server_name']}-ssl" do
  owner "root"
  group "root"
  mode 00644
  source node['shared_hosting']['apache_shared_ldap']['ssl_site_template']
  variables(
    :server_name => node['shared_hosting']['apache_shared_ldap']['server_name'],
    :document_root => "#{node['shared_hosting']['apache2']['sites_dir']}/#{node['shared_hosting']['apache_shared_ldap']['server_name']}",
    :ssl_cert_file => node['shared_hosting']['apache_shared_ldap']['ssl_cert_file'],
    :ssl_cert_key => node['shared_hosting']['apache_shared_ldap']['ssl_cert_key']
  )
  notifies :reload, "service[apache2]"
end

# Enable the site configurations
link "#{node['apache']['dir']}/sites-enabled/#{node['shared_hosting']['apache_shared_ldap']['server_name']}" do
  to "#{node['apache']['dir']}/sites-available/#{node['shared_hosting']['apache_shared_ldap']['server_name']}"
  notifies :reload, "service[apache2]"
end

link "#{node['apache']['dir']}/sites-enabled/#{node['shared_hosting']['apache_shared_ldap']['server_name']}-ssl" do
  to "#{node['apache']['dir']}/sites-available/#{node['shared_hosting']['apache_shared_ldap']['server_name']}-ssl"
  notifies :reload, "service[apache2]"
end

# Enable the userdir module
link "#{node['apache']['dir']}/mods-enabled/userdir.conf" do
  to "#{node['apache']['dir']}/mods-available/userdir.conf"
  notifies :reload, "service[apache2]"
end

link "#{node['apache']['dir']}/mods-enabled/userdir.load" do
  to "#{node['apache']['dir']}/mods-available/userdir.load"
  notifies :reload, "service[apache2]"
end

# Create a directory for user homes
directory node['shared_hosting']['apache_shared_ldap']['home_prefix'] do
  owner "root"
  group "root"
  mode 00755
  action :create
end

# Give the www-data group default read and execute permissions on the user home directories
execute "Set ACLs on userdirs" do
  command "setfacl -d -m g:www-data:rx #{node['shared_hosting']['apache_shared_ldap']['home_prefix']}"
  action :run
end

# Get LDAP authentication info using chef-vault
begin
  bind_credentials = chef_vault_item(node['shared_hosting']['apache_shared_ldap']['chef_vault'], node['shared_hosting']['apache_shared_ldap']['chef_vault_item'])
rescue
  log 'Unable to load chef vault item. Skipping configuration.'
end

if (bind_credentials)
  # Connect to the LDAP server
  ldap = Net::LDAP.new  :host => node['shared_hosting']['apache_shared_ldap']['ldap_host'],
                        :port => node['shared_hosting']['apache_shared_ldap']['ldap_port'],
                        :encryption => node['shared_hosting']['apache_shared_ldap']['ldap_encryption'],
                        :base => node['shared_hosting']['apache_shared_ldap']['ldap_base'],
                        :auth => {
                          :method => :simple,
                          :username => bind_credentials['username'],
                          :password => bind_credentials['password']
                        }

  # Search for users in the group specified
  search_filter = Net::LDAP::Filter.eq("memberOf", node['shared_hosting']['apache_shared_ldap']['ldap_group_dn'])
  group_filter = Net::LDAP::Filter.eq("objectClass", "user")
  composite_filter = Net::LDAP::Filter.join(search_filter, group_filter)

  matching_users = Array.new
  ldap.search(:filter => search_filter) do |item|
    matching_users << item.sAMAccountName.first
  end

  # Continue if the search was successful
  if (ldap.get_operation_result.code == 0)
    # Set up a site for each user in the LDAP group
    matching_users.each do |u|
      # Create the user's home directory with appropriate permissions
      directory "#{node['shared_hosting']['apache_shared_ldap']['home_prefix']}/#{u}" do
        owner "root"
        group node['shared_hosting']['chroot_group']
        mode 00750
        action :create
      end

      # Create a public_html directory inside the user's home
      directory "#{node['shared_hosting']['apache_shared_ldap']['home_prefix']}/#{u}/public_html" do
        owner u
        group "root"
        mode 00750
        action :create
      end
    end
  else
    log "Unable to enumerate the LDAP group."
  end
end