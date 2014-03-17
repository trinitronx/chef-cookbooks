#
# Cookbook Name:: bacula
# Recipe:: storage
#
# Copyright 2012, computerlyrik
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

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

node.set_unless['bacula']['sd']['password'] = secure_password
node.set_unless['bacula']['sd']['password_monitor'] = secure_password
node.save

# Setup tape drive hardware compression before package install
include_recipe "bacula::hardwarecompression"

package "bacula-sd-mysql"
service "bacula-sd"

# TODO - Allow for automatic service restarting when idle
# Script needs to be updated to account for multiple storage devices
#
# Setup service restart resource
package 'python-pexpect'
#template '/usr/local/sbin/restart_bacula_sd.py' do
#  source 'restart_bacula_sd.py.erb'
#  mode 0755
#end
#execute 'restart_bacula_sd' do
#  action :nothing
#  command '/usr/bin/run-one /usr/bin/python /usr/local/sbin/restart_bacula_sd.py > /dev/null 2>&1 &'
#end


# Find directors
ourdirectors = []
search(:node, "roles:#{node['bacula']['directorrole']}").each do |nodeobj|
  ourdirectors << nodeobj.name
end

# This template won't automatically restart the director (to avoid interrupting jobs)
template "/etc/bacula/bacula-sd.conf" do
  group node['bacula']['group']
  mode 0640
  variables ({
    :directors => ourdirectors
  })
end
