#
# Cookbook Name:: shared_hosting
# Recipe:: ssl
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

# Create a self-signed SSL certificate
directory "#{node['nginx']['dir']}/certs" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

bash "Create SSL Certificate" do
  cwd "#{node['nginx']['dir']}/certs"
  code <<-EOH
  umask 077
  openssl genrsa 2048 > selfsigned.key
  openssl req -subj "#{node['shared_hosting']['ssl_req']}" -new -x509 -nodes -sha1 -days 3650 -key selfsigned.key > selfsigned.crt
  EOH
  not_if { ::File.exists?("#{node['shared_hosting']['ssl_cert_file']}") }
end

# Add nginx SSL configuration
template "#{node['nginx']['dir']}/conf.d/ssl.conf" do
  owner "root"
  group "root"
  mode 00644
  source "nginx-ssl.conf.erb"
  variables(
    :ssl_cert_file => node['shared_hosting']['ssl_cert_file'],
    :ssl_cert_key => node['shared_hosting']['ssl_cert_key'],
  )
  notifies :reload, "service[nginx]"
end