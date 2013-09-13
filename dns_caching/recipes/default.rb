#
# Cookbook Name:: dns_caching
# Recipe:: default
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

# Requires resolver attributes to be set
if node['resolver']['nameservers'].empty? || node['resolver']['nameservers'][0].empty?
  Chef::Log.warn("#{cookbook_name}::#{recipe_name} requires that attribute ['resolver']['nameservers'] is set.")
  Chef::Log.info("#{cookbook_name}::#{recipe_name} will exit to prevent a potential breaking change in /etc/resolv.conf.")
  return
else
  # For platforms besides Ubuntu 12+
  unless node['platform'] == 'ubuntu' && node['platform_version'].to_i >= 12
    # Install dnsmasq package
    package "dnsmasq"

    template "/etc/dnsmasq.d/dns_caching.conf" do
      source "dns_caching.conf.erb"
      owner "root"
      group "root"
      mode 00644
      notifies :restart, "service[dnsmasq]"
    end

    # Install dnsmasq package
    package "dnsmasq"

    # Restart the dnsmasq service only if configuration changes were made
    service "dnsmasq" do
      action :nothing
    end

    # Use the resolver cookbook to update /etc/resolv.conf
    include_recipe "resolver"
  # For Ubuntu 12+ systems
  else
    # Pre-stage the dnsmasq configuration file and defaults file
    directory "/etc/dnsmasq.d" do
      owner "root"
      group "root"
      mode 0755
    end

    template "/etc/dnsmasq.d/dns_caching.conf" do
      source "dns_caching.conf.erb"
      owner "root"
      group "root"
      mode 00644
      if File.exists?('/etc/dnsmasq.conf')
        notifies :restart, "service[dnsmasq]"
      end
    end

    template "/etc/default/dnsmasq" do
      source "dnsmasq.erb"
      owner "root"
      group "root"
      mode 00644
    end

    # Install dnsmasq package, keeping the pre-staged configuration files
    package "dnsmasq" do
      options '-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
      action :install
    end

    # Restart the dnsmasq service only if configuration changes were made
    service "dnsmasq" do
      action :nothing
    end
  end
end