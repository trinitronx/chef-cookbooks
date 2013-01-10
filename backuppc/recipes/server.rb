#
# Cookbook Name:: backuppc
# Recipe:: server 
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

# Install backuppc
package "backuppc" do
  action :install
end

# Setup apache virtual server

link "/etc/apache2/sites-available/backuppc" do
  to "/etc/backuppc/apache.conf"
end

link "/etc/apache2/sites-enabled/backuppc" do
  to "/etc/apache2/sites-available/backuppc"
  notifies :restart, "service[apache2]"
end

service "apache2" do
  supports :restart => true, :reload => true
  action [ :enable, :start ]
end

# Since backuppc package installation will generate an unknown
# httpasswd for the backuppc user, allow for an attribute override of
# the password
if node.has_key? "backuppc"
  if node['backuppc'].has_key? "server"
    if node['backuppc']['server'].has_key? "webadminpassword"
      include_recipe "htpasswd::default"
      htpasswd "/etc/backuppc/htpasswd" do
        user "backuppc"
        password node['backuppc']['server']['webadminpassword']
      end
    end
  end
end
