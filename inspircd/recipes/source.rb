#
# Cookbook Name:: inspircd
# Recipe:: source 
#
# Copyright 2012, Biola University
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

package "libgnutls26" do
	not_if "test -f /usr/lib/x86_64-linux-gnu/libgnutls.so.26"	
	action :install
	end

package "libldap-2.4-2" do
	not_if "test -f /usr/lib/x86_64-linux-gnu/libldap-2.4.so.2"	
	action :install
	end

package "pkg-config" do
	not_if "test -f /usr/bin/pkg-config"	
	action :install
	end

template "/etc/init.d/inspircd" do
  source "init.d_inspircd.erb"
  mode 0755
  end

service "inspircd" do
  supports :status => true, :restart => true, :reload => true
end

remote_file "#{Chef::Config[:file_cache_path]}/inspircd_2.0.8.tar.bz2" do
  not_if "test -f " + node[:inspircd][:binary_location]
  source "inspircd_2.0.8.tar.bz2"
  action :create_if_missing
  end


directory node[:inspircd][:inspircd_directory] do
  mode 0755
  owner "irc"
  group "adm"
  action :create
end

execute "InstallInspircdFromCookbookPackage" do
	command "tar -jxf " + Chef::Config[:file_cache_path] + "/inspircd_2.0.8.tar.bz2 --directory=" + node[:inspircd][:inspircd_directory]
	creates node[:inspircd][:binary_location]
	notifies :restart, "service[inspircd]"
	end


directory node[:inspircd][:inspircd_directory] + "/conf" do
  mode 0700
  owner "irc"
  group "adm"
  action :create
end
template node[:inspircd][:inspircd_directory] + "/conf/inspircd.motd" do
  source "inspircd.motd.erb"
  owner "irc"
  group "adm"
  notifies :reload, "service[inspircd]"
  end
template node[:inspircd][:inspircd_directory] + "/conf/inspircd.conf" do
  source "inspircd.conf.erb"
  owner "irc"
  group "adm"
  notifies :reload, "service[inspircd]"
  end
template node[:inspircd][:inspircd_directory] + "/conf/inspircd.rules" do
  source "inspircd.rules.erb"
  owner "irc"
  group "adm"
  notifies :reload, "service[inspircd]"
  end


bash "Ensure inspircd runs and stops at default runlevels" do
	user "root"
	code <<-EOH
	update-rc.d inspircd defaults
	EOH
	end

file node[:inspircd][:chatlog_location] do
  owner "irc"
  group "adm"
  mode "0600"
  action :create_if_missing
  end

file "/var/log/inspircd.log" do
  owner "irc"
  group "adm"
  mode "0644"
  action :create_if_missing
  end



# If ssl cert location is specified, and no private key is present, generate it
if node[:inspircd][:ssl_cert_location]

execute "sslcertgeneration" do
	command "openssl req -x509 -nodes -days 1825 -subj '" + node[:inspircd][:ssl_subj_stanza] + "' -newkey rsa:1024 -keyout " + node[:inspircd][:ssl_key_location] + " -out " + node[:inspircd][:ssl_cert_location]
	creates node[:inspircd][:ssl_cert_location]
	end

file node[:inspircd][:ssl_cert_location] do
  owner "irc"
  group "adm"
  mode "0600"
  action :create
  end

file node[:inspircd][:ssl_key_location] do
  owner "irc"
  group "adm"
  mode "0600"
  action :create
  end


end	

# Setup logrotate
include_recipe "logrotate::default"

logrotate_app "inspircd" do
  cookbook "logrotate"
  path [ "/var/log/inspircd.log", "/var/log/inspircd_chat.log" ]
  frequency "daily"
  rotate 7
  create "600 root adm"
end


