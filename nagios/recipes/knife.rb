#
# Cookbook Name:: nagios
# Recipe:: knife
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

# Deploy knife configuration
template "#{node['nagios']['conf_dir']}/knife.rb" do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode 00640
  source "knife.rb.erb"
end

# Change the owner of the client key so Nagios can access the Chef server
file "/etc/chef/client.pem" do
	owner "nagios"
end