#
# Cookbook Name:: tftpd-hpa
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

# Install tftpd-hpa
package "tftpd-hpa" do
  action :install
end

# Set up the tftpd-hpa service
service "tftpd-hpa" do
  supports :start => true, :restart => true, :stop => true
  action [ :enable, :start ]
end

# Create a TFTP directory to use
directory node['tftpd-hpa']['tftp_directory'] do
  user "tftp"
  group "tftp"
  mode '0777'
  action :create
end

# Set up the configuration file
template "/etc/default/tftpd-hpa" do
  source "tftpd-hpa.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :tftp_directory => node['tftpd-hpa']['tftp_directory']
  )
  notifies :restart, resources(:service => "tftpd-hpa")
end