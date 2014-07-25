#
# Cookbook Name:: shared_hosting
# Recipe:: apache2
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

# Install Apache
include_recipe "apache2::default"
include_recipe "apache2::mod_ssl"
include_recipe "shared_hosting::default"

# Service definitions
service "apache2" do
  supports :restart => true, :reload => true
  action :nothing
end

# Create a directory for Apache sites
directory node['shared_hosting']['apache2']['sites_dir'] do
  owner "root"
  group "root"
  mode 00755
  action :create
end

# Create a directory and index for the default Apache site
directory "#{node['shared_hosting']['apache2']['sites_dir']}/apache2-default" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

cookbook_file "#{node['shared_hosting']['apache2']['sites_dir']}/apache2-default/index.html" do
  source "404.html"
  owner "root"
  group "root"
  mode 00644
  action :create
end

# Create the Apache default site configuration
template "#{node['apache']['dir']}/sites-available/#{node['hostname']}" do
  owner "root"
  group "root"
  mode 00644
  source "apache2-default-site.erb"
  notifies :reload, "service[apache2]"
end

# Create the Apache default site SSL configuration
template "#{node['apache']['dir']}/sites-available/#{node['hostname']}-ssl" do
  owner "root"
  group "root"
  mode 00644
  source "apache2-default-site-ssl.erb"
  notifies :reload, "service[apache2]"
end

# Enable the Apache site configuration
link "#{node['apache']['dir']}/sites-enabled/#{node['hostname']}" do
  to "#{node['apache']['dir']}/sites-available/#{node['hostname']}"
  notifies :reload, "service[apache2]"
end

link "#{node['apache']['dir']}/sites-enabled/#{node['hostname']}-ssl" do
  to "#{node['apache']['dir']}/sites-available/#{node['hostname']}-ssl"
  notifies :reload, "service[apache2]"
end

# Disable the built-in Apache default site if needed
link "#{node['apache']['dir']}/sites-enabled/000-default" do
  action :delete
  only_if "test -L #{node['apache']['dir']}/sites-enabled/000-default"
  notifies :reload, "service[apache2]"
end

# Give the www-data group default read and execute permissions on the Apache sites
execute "Set ACLs on Apache sites" do
  command "setfacl -d -m g:www-data:rx #{node['shared_hosting']['apache2']['sites_dir']}"
  action :run
end