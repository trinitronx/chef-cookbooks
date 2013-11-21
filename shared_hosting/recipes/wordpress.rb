#
# Cookbook Name:: shared_hosting
# Recipe:: wordpress
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

# Install nginx and PHP
include_recipe "nginx::default"
include_recipe "php::default"

# Install required PHP packages
%w{ php5-fpm php5-mysql php5-suhosin }.each do |pkg|
  package pkg
end

# Install extra PHP packages
node['shared_hosting']['wordpress']['php_packages'].each do |pkg|
  package pkg
end

# Install phpmyadmin
package "phpmyadmin"

# Install the acl package and re-mount the /srv partition with acl support
package "acl" do
  notifies :disable, "mount[srv]", :immediately
  notifies :enable, "mount[srv]", :immediately
  notifies :run, "execute[remount-srv]", :immediately
end

mount "srv" do
  mount_point "/srv"
  device "/dev/mapper/VolGroup1-LogVolSrv"
  fstype "ext4"
  options "defaults,acl"
  action :nothing
end

execute "remount-srv" do
  command "mount -o remount /srv"
  action :nothing
end

# Service definitions
service "nginx" do
  supports :restart => true, :reload => true
  action :nothing
end
service "php5-fpm" do
  supports :restart => true, :reload => true
  action :nothing
end
service "ssh" do
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
  openssl req -subj "#{node['shared_hosting']['wordpress']['ssl_req']}" -new -x509 -nodes -sha1 -days 3650 -key selfsigned.key > selfsigned.crt
  EOH
  not_if { ::File.exists?("#{node['shared_hosting']['wordpress']['ssl_cert_file']}") }
end

# Add nginx SSL configuration
template "#{node['nginx']['dir']}/conf.d/ssl.conf" do
  owner "root"
  group "root"
  mode 00644
  source "nginx-ssl.conf.erb"
  variables(
    :ssl_cert_file => node['shared_hosting']['wordpress']['ssl_cert_file'],
    :ssl_cert_key => node['shared_hosting']['wordpress']['ssl_cert_key'],
  )
  notifies :reload, "service[nginx]"
end

# Create a directory for nginx sites
directory node['shared_hosting']['wordpress']['sites_dir'] do
  owner "root"
  group "root"
  mode 00755
  action :create
end

# Create a directory and index for the default nginx site
directory "#{node['shared_hosting']['wordpress']['sites_dir']}/nginx-default" do
  owner "root"
  group "root"
  mode 00755
  action :create
end

cookbook_file "#{node['shared_hosting']['wordpress']['sites_dir']}/nginx-default/index.html" do
  source "404.html"
  owner "root"
  group "root"
  mode 00644
  action :create
end

# Update the config for the default nginx site
template "#{node['nginx']['dir']}/sites-available/#{node['hostname']}" do
  owner "root"
  group "root"
  mode 00644
  source "nginx-default-site.erb"
  variables(
    :site_name => "localhost",
    :server_name => node['hostname'],
    :site_root => node['shared_hosting']['wordpress']['sites_dir'],
    :document_root => "/nginx-default"
  )
  notifies :reload, "service[nginx]"
end

# Enable the default site configuration
link "/etc/nginx/sites-enabled/#{node['hostname']}" do
  to "/etc/nginx/sites-available/#{node['hostname']}"
  notifies :reload, "service[nginx]"
end

# Give the www-data group default read and execute permissions on the nginx sites
execute "Set ACLs on nginx sites" do
  command "setfacl -d -m g:www-data:rx #{node['shared_hosting']['wordpress']['sites_dir']}"
  action :run
end

# Add any extra nginx configuration files
remote_directory "#{node['nginx']['dir']}/conf.d" do
  source "wordpress"
  files_owner "root"
  files_group "root"
  files_mode 00644
end

# Create a directory to hold Unix sockets for the php-fpm pools
directory node['shared_hosting']['wordpress']['socket_dir'] do
  owner "root"
  group "root"
  mode 00755
  action :create
end

# Remove the default php-fpm pool configuration
file "/etc/php5/fpm/pool.d/www.conf" do
  action :delete
end

# Create a new php-fpm pool configuration for phpmyadmin
template "/etc/php5/fpm/pool.d/phpmyadmin.conf" do
  owner "root"
  group "root"
  mode 00644
  source "php-fpm-pool.conf.erb"
  variables(
    :site_name => "phpmyadmin",
    :user_name => "www-data",
    :socket_dir => node['shared_hosting']['wordpress']['socket_dir'],
    :php_restrict_basedir => false,
    :php_admin_flags => {"suhosin.simulation" => "On"}
  )
  notifies :restart, "service[php5-fpm]"
end

# Retrieve encryption key for databag items
encryption_key = Chef::EncryptedDataBagItem.load_secret(node['mysql']['management']['databag_encryption_key'])
pma_user = Chef::EncryptedDataBagItem.load(node['mysql']['management']['users_databag'], 'phpmyadmin', encryption_key)
root_user = Chef::EncryptedDataBagItem.load(node['mysql']['management']['users_databag'], 'root', encryption_key)

# Replace the phpmyadmin database config file
template "/etc/phpmyadmin/config-db.php" do
  owner "root"
  group "www-data"
  mode 00640
  source "config-db.php.erb"
  variables(
    :dbpass => pma_user['password']
  )
end

# Create the tables for phpmyadmin
execute "Create tables" do
  command "gunzip /usr/share/doc/phpmyadmin/examples/create_tables.sql.gz; mysql -uroot -p#{root_user['password']} < /usr/share/doc/phpmyadmin/examples/create_tables.sql"
  creates "/usr/share/doc/phpmyadmin/examples/create_tables.sql"
  action :run
end

# Create a group for users that need to be chrooted when using SFTP
group node['shared_hosting']['wordpress']['chroot_group'] do
  action :create
end

# Configure openssh to chroot users in the group specified in the ['shared_hosting']['wordpress']['chroot_group'] attribute
template "/etc/ssh/sshd_config" do
  owner "root"
  group "root"
  mode 00644
  source "sshd_config.erb"
  variables(
    :chroot_group => node['shared_hosting']['wordpress']['chroot_group']
  )
  notifies :restart, "service[ssh]"
end

# Set up each of the wordpress sites configured in node attributes
if node['shared_hosting']['wordpress']['sites']
  node['shared_hosting']['wordpress']['sites'].each do |site|
    site.each do |site_key, site_value|
      # Create a user account with a home folder in the wordpress sites directory
      account_name = site_value['user_name'].nil? ? site_key.to_s : site_value['user_name']
      user account_name do
        home "#{node['shared_hosting']['wordpress']['sites_dir']}/#{site_key.to_s}"
        shell "/bin/bash"
        action :create
      end

      # Create the user's home directory with appropriate permissions
      directory "#{node['shared_hosting']['wordpress']['sites_dir']}/#{site_key.to_s}" do
        unless site_value['chroot_user'] == false
          owner "root"
          group account_name
        else
          owner account_name
          group account_name
        end
        mode 00750
        action :create
      end

      # Add the account to the chrooted group if specified
      unless site_value['chroot_user'] == false
        group node['shared_hosting']['wordpress']['chroot_group'] do
          action :modify
          members account_name
          append true
        end
      end

      # Create a new php-fpm pool configuration for the site
      template "/etc/php5/fpm/pool.d/#{site_key.to_s}.conf" do
        owner "root"
        group "root"
        mode 00644
        source "php-fpm-pool.conf.erb"
        variables(
          :site_name => site_key.to_s,
          :user_name => account_name,
          :socket_dir => node['shared_hosting']['wordpress']['socket_dir'],
          :sites_dir => node['shared_hosting']['wordpress']['sites_dir'],
          :php_restrict_basedir => site_value['php_restrict_basedir'],
          :enable_mail => site_value['enable_mail'],
          :php_admin_flags => site_value['php_admin_flags'],
          :php_admin_values => site_value['php_admin_values']
        )
        notifies :restart, "service[php5-fpm]"
      end

      # Create a public_html directory inside the user's home
      directory "#{node['shared_hosting']['wordpress']['sites_dir']}/#{site_key.to_s}/public_html" do
        owner account_name
        group account_name
        mode 00750
        action :create
      end

      # Create a new nginx site configuration
      nginx_template = site_value['nginx_template'].nil? ? "wordpress-default-site.erb" : site_value['nginx_template']
      template "/etc/nginx/sites-available/#{site_key.to_s}" do
        owner "root"
        group "root"
        mode 00644
        source nginx_template
        variables(
          :site_name => site_key.to_s,
          :server_name => site_value['server_name'],
          :include => site_value['nginx_include'],
          :site_root => "#{node['shared_hosting']['wordpress']['sites_dir']}/#{site_key.to_s}",
          :document_root => "/public_html",
          :fastcgi_pass => "unix:#{node['shared_hosting']['wordpress']['socket_dir']}/#{site_key.to_s}.sock"
        )
        notifies :reload, "service[nginx]"
      end

      # Enable the nginx site configuration
      link "/etc/nginx/sites-enabled/#{site_key.to_s}" do
        to "/etc/nginx/sites-available/#{site_key.to_s}"
        notifies :reload, "service[nginx]"
      end
    end
  end
end