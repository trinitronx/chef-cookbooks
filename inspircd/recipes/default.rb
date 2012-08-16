#
# Cookbook Name:: inspircd
# Recipe:: default
#
# Copyright 2012, Biola University
#
# All rights reserved - Do Not Redistribute
#
case node[:platform_version]
when '12.04'
    package "libgeoip1" do
	not_if "test -f /usr/sbin/inspircd"	
	action :install
	end
    package "libgnutls26" do
	not_if "test -f /usr/sbin/inspircd"
        action :install
	end
    package "libldap-2.4-2" do
	not_if "test -f /usr/sbin/inspircd"
        action :install
        end
    package "libmysqlclient18" do
	not_if "test -f /usr/sbin/inspircd"
        action :install
        end
    package "libpq5" do
	not_if "test -f /usr/sbin/inspircd"
        action :install
        end
    package "libtre5" do
	not_if "test -f /usr/sbin/inspircd"
        action :install
        end
    remote_file "#{Chef::Config[:file_cache_path]}/inspircd_2.0.5-1_amd64.deb" do
	not_if "test -f /usr/sbin/inspircd"
	source "inspircd_2.0.5-1_amd64.deb"
	action :create_if_missing
	end
    bash "Install inspircd quantal package" do
	not_if "test -f /usr/sbin/inspircd"
	user "root"
	cwd Chef::Config[:file_cache_path]
	code <<-EOH
	dpkg -i inspircd_2.0.5-1_amd64.deb
	EOH
	end
    package "gnutls-bin" do
        not_if "test -f /usr/bin/gnutls-cli"
        action :install
        end
    package "libgnutls-dev" do
        not_if "test -f /usr/include/gnutls/gnutls.h"
        action :install
        end
    package "pkg-config" do
        not_if "test -f /usr/bin/pkg-config"
        action :install
        end
else
    package "inspircd" do
	not_if "test -f /usr/sbin/inspircd"
	action :install
    end
    package "gnutls-bin" do
        not_if "test -f /usr/bin/gnutls-cli"
        action :install
        end
    package "libgnutls-dev" do
        not_if "test -f /usr/include/gnutls/gnutls.h"
        action :install
        end
    package "pkg-config" do
        not_if "test -f /usr/bin/pkg-config"
        action :install
        end
end
template "/etc/inspircd/inspircd.motd" do
  source "inspircd.motd.erb"
  owner "irc"
  group "adm"
#  variables({
#    :x_men => "are keen"
#  })
## Commented out during development
#  notifies :reload, "service[inspircd]"
  end
template "/etc/inspircd/inspircd.conf" do
  source "inspircd.conf.erb"
  owner "irc"
  group "adm"
## Commented out during development
#  notifies :reload, "service[inspircd]"
  end
template "/etc/inspircd/inspircd.rules" do
  source "inspircd.rules.erb"
  owner "irc"
  group "adm"
## Commented out during development
#  notifies :reload, "service[inspircd]"
  end
template "/etc/default/inspircd" do
  source "inspircd.erb"
  end
