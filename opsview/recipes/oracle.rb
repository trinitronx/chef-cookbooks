#
# Cookbook Name:: opsview
# Recipe:: oracle
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

# Install Oracle Instant Client and dependencies
include_recipe "oracle_instant_client::default"
package "libdbi-perl"

# Build and install DBD::Oracle
remote_file "#{Chef::Config[:file_cache_path]}/DBD-Oracle-#{node['opsview']['oracle']['dbd_oracle_version']}.tar.gz" do
  source node['opsview']['oracle']['dbd_oracle_url']
  checksum node['opsview']['oracle']['dbd_oracle_checksum']
  action :create_if_missing
end

lib_path = Dir[File.join(node['oracle_instant_client']['base_dir'], 'instantclient*')].find { |f| File.directory?(f) }
bash 'build-dbd-oracle' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf DBD-Oracle-#{node['opsview']['oracle']['dbd_oracle_version']}.tar.gz
    cd DBD-Oracle-#{node['opsview']['oracle']['dbd_oracle_version']}
    perl Makefile.PL
    make
    make install
  EOH
  environment 'LD_LIBRARY_PATH' => lib_path
  creates '/usr/local/lib/perl/5.14.2/DBD/Oracle.pm'
end

# Build and install the check_oracle_health plugin
remote_file "#{Chef::Config[:file_cache_path]}/check_oracle_health-#{node['opsview']['oracle']['plugin_version']}.tar.gz" do
  source node['opsview']['oracle']['plugin_url']
  checksum node['opsview']['oracle']['plugin_checksum']
  action :create_if_missing
end

bash 'build-check-oracle' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf check_oracle_health-#{node['opsview']['oracle']['plugin_version']}.tar.gz
    cd check_oracle_health-#{node['opsview']['oracle']['plugin_version']}
    ./configure --prefix=/usr/local/nagios \
      --with-nagios-user=nagios \
      --with-nagios-group=nagios \
      --with-perl=/usr/bin/perl \
      --with-statefiles-dir=/tmp
    make
    make install
  EOH
  creates '/usr/local/nagios/libexec/check_oracle_health'
end