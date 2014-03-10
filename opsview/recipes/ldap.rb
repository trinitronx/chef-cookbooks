#
# Cookbook Name:: opsview
# Recipe:: ldap
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

include_recipe 'chef-vault'

# Get LDAP authentication info using chef-vault
ldap_bind_account = chef_vault_item(node['opsview']['ldap']['vault'], node['opsview']['ldap']['vault_item'])

# Add LDAP configuration
template "/usr/local/opsview-web/opsview_web_local.yml" do
  source "opsview_web_local.yml.erb"
  owner "nagios"
  group "nagios"
  mode 00600
  variables(
    :ldap_bind_account => ldap_bind_account
  )
  notifies :restart, "service[opsview-web]"
end

# Add LDAP group configuration
directory node['opsview']['ldap']['group_dir'] do
  owner "nagios"
  group "nagios"
  action :create
end

node['opsview']['ldap']['groups'].each do |group|
  template "#{node['opsview']['ldap']['group_dir']}/#{group}.xml" do
    source "ldap_group.xml.erb"
    owner "nagios"
    group "nagios"
    mode 00644
    variables(
      :group => group
    )
    notifies :run, "execute[Sync LDAP accounts]"
  end
end

service "opsview-web" do
  action :nothing
end

execute "Sync LDAP accounts" do
  command "/usr/local/nagios/bin/opsview_sync_ldap -y"
  action :nothing
end