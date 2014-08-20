#
# Cookbook Name:: opsview
# Recipe:: check_mssql
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

# Install DBD::Sybase Perl module
package "libdbd-sybase-perl"

# Replace the default FreeTDS config
template "/etc/freetds/freetds.conf" do
  source "freetds.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

# Build and install the check_mssql_health plugin
remote_file "#{Chef::Config[:file_cache_path]}/check_mssql_health-#{node['opsview']['check_mssql']['plugin_version']}.tar.gz" do
  source node['opsview']['check_mssql']['plugin_url']
  checksum node['opsview']['check_mssql']['plugin_checksum']
  action :create_if_missing
end

bash 'build-check-mssql' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf check_mssql_health-#{node['opsview']['check_mssql']['plugin_version']}.tar.gz
    cd check_mssql_health-#{node['opsview']['check_mssql']['plugin_version']}
    ./configure --prefix=/usr/local/nagios \
      --with-nagios-user=nagios \
      --with-nagios-group=nagios \
      --with-perl=/usr/bin/perl \
      --with-statefiles-dir=#{node['opsview']['check_mssql']['statefiles_dir']}
    make
    make install
  EOH
  creates '/usr/local/nagios/libexec/check_mssql_health'
end