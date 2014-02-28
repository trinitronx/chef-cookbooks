#
# Cookbook Name:: postfix_biola
# Recipe:: sasl_ldap
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

# Install the chef-vault gem
chef_gem "chef-vault"
require 'chef-vault'

# Install sasl2-bin
package "sasl2-bin" do
  action :install
  notifies :run, "execute[fix saslauthd permissions]"
end

execute "fix saslauthd permissions" do
 command "dpkg-statoverride --force --update --add root sasl 755 /var/run/saslauthd"
 action :nothing
end

# Add the postfix user to the sasl group
group "sasl" do
  action :modify
  members "postfix"
  append true
end

# Configure Postfix sasl configuration
template "/etc/postfix/sasl/smtpd.conf" do
  source "smtpd.conf.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :restart, "service[postfix]"
end

# Update default saslauthd configuration
template "/etc/default/saslauthd" do
  source "saslauthd.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :restart, "service[saslauthd]"
end

# Get LDAP authentication info using chef-vault
ldap_bind_account = ChefVault::Item.load(node['postfix']['sasl']['vault'], node['postfix']['sasl']['vault_item'])

# Add saslauthd LDAP configuration
template "/etc/saslauthd.conf" do
  source "saslauthd.conf.erb"
  owner "root"
  group "root"
  mode 00600
  variables(
    :ldap_bind_account => ldap_bind_account
  )
  notifies :restart, "service[saslauthd]"
end

service "postfix" do
  action :nothing
end

service "saslauthd" do
  action :nothing
end