#
# Cookbook Name:: ohai_plugins
# Recipe:: rfc1918ipaddress
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

plugindir = ''
if node['os'] == 'windows'
  plugindir = 'C:/chef/ohai_plugins'
elsif node['os'] == 'linux'
  plugindir = '/etc/chef/ohai_plugins'
end

# Setup reload when the plugin is first deployed
ohai "reload_ohai" do
  action :nothing
end

# Ensure the directory exists
directory plugindir

# Deploy the plugin
cookbook_file "#{plugindir}/rfc1918ipaddress.rb" do
  source 'rfc1918ipaddress.rb'
  notifies :reload, "ohai[reload_ohai]", :immediately
end
