#
# Cookbook Name:: shared_hosting
# Recipe:: change_password
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

# Install expect
package "expect"

# Install the scripts
%w{ change_password.sh change_password_expect.sh }.each do |script|
  template "#{node['shared_hosting']['change_password']['script_path']}/#{script}" do
    owner "root"
    group "root"
    mode 00755
    source "#{script}.erb"
  end
end

# Create a dummy user
user node['shared_hosting']['change_password']['dummy_user'] do
  comment "Dummy user for changing passwords via ssh"
  home "/home/#{node['shared_hosting']['change_password']['dummy_user']}"
  shell "#{node['shared_hosting']['change_password']['script_path']}/change_password.sh"
  system true
  password node['shared_hosting']['change_password']['dummy_password']
  action :create
end