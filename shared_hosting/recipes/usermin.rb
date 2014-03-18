#
# Cookbook Name:: shared_hosting
# Recipe:: usermin
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

# Add repositories for webmin
apt_repository "webmin" do
  uri "http://download.webmin.com/download/repository"
  distribution "sarge"
  components ["contrib"]
  key "http://www.webmin.com/jcameron-key.asc"
  action :add
end

apt_repository "webmin-mirror" do
  uri "http://webmin.mirror.somersettechsolutions.co.uk/repository"
  distribution "sarge"
  components ["contrib"]
  key "http://www.webmin.com/jcameron-key.asc"
  action :add
end

# Install usermin
package "usermin"

# Service definitions
service "usermin" do
  supports :restart => true, :reload => true
  action :nothing
end

# Update usermin configuration
template "/etc/usermin/miniserv.conf" do
  owner "root"
  group "bin"
  mode 00755
  source "miniserv.conf.erb"
  notifies :reload, "service[usermin]"
end

template "/etc/usermin/webmin.acl" do
  owner "root"
  group "bin"
  mode 00755
  source "webmin.acl.erb"
  notifies :reload, "service[usermin]"
end

# Set options for changing passwords
template "/etc/usermin/changepass/config" do
  owner "root"
  group "bin"
  mode 00755
  source "changepass_config.erb"
  notifies :reload, "service[usermin]"
end

# Restrict the file manager to home directories
if node['shared_hosting']['usermin_home_only'] == 1
  execute "update file manager" do
    command "sed -i 's/home_only=0/home_only=1/' /etc/usermin/file/config"
    not_if "grep 'home_only=1' /etc/usermin/file/config"
    action :run
  end
end