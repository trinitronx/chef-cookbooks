#
# Cookbook Name:: shared_hosting
# Recipe:: default-site
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

# Install nginx
include_recipe "nginx::default"

# Service definitions
service "nginx" do
  supports :restart => true, :reload => true
  action :nothing
end

# Create a directory for nginx sites
directory node['shared_hosting']['sites_dir'] do
  owner "root"
  group "root"
  mode 00755
  action :create
end

# Create a directory and index for the default nginx site
directory "#{node['shared_hosting']['sites_dir']}/nginx-default" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

cookbook_file "#{node['shared_hosting']['sites_dir']}/nginx-default/index.html" do
  source "404.html"
  owner "root"
  group "root"
  mode 00644
  action :create
end

# Create the nginx site configuration
template "/etc/nginx/sites-available/#{node['hostname']}" do
  owner "root"
  group "root"
  mode 00644
  source "nginx-default-site.erb"
  variables(
    :site_name => "localhost",
    :server_name => node['hostname'],
    :site_root => node['shared_hosting']['sites_dir'],
    :document_root => "/nginx-default"
  )
  notifies :reload, "service[nginx]"
end

# Enable the nginx site configuration
link "/etc/nginx/sites-enabled/#{node['hostname']}" do
  to "/etc/nginx/sites-available/#{node['hostname']}"
  notifies :reload, "service[nginx]"
end