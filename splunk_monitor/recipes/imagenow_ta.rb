#
# Cookbook Name:: splunk_monitor
# Recipe:: imagenow_ta 
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

# Setting the file to download locally and install, so that version upgrades (or
# downgrades) will trigger app reinstallation

case node[:os]
when "windows"
  service "SplunkForwarder" do
    action [ :nothing ]
    supports :status => true, :start => true, :stop => true, :restart => true
  end
end

directory "#{node['splunk']['forwarder_home']}/etc/apps/TA-imagenow" do
  action :create
end

directory "#{node['splunk']['forwarder_home']}/etc/apps/TA-imagenow/default" do
  action :create
end

directory "#{node['splunk']['forwarder_home']}/etc/apps/TA-imagenow/bin" do
  action :create
end

cookbook_file "#{node['splunk']['forwarder_home']}/etc/apps/TA-imagenow/README.txt" do
  source "ta_imagenow-README.txt"
  backup false
end

cookbook_file "#{node['splunk']['forwarder_home']}/etc/apps/TA-imagenow/default/app.conf" do
  source "ta_imagenow-app.conf"
end

template "#{node['splunk']['forwarder_home']}/etc/apps/TA-imagenow/bin/check_imagenow_usercount.bat" do
  source "ta_imagenow-check_imagenow_usercount.bat.erb"
  notifies :restart, resources(:service => "SplunkForwarder")
end

template "#{node['splunk']['forwarder_home']}/etc/apps/TA-imagenow/bin/check_imagenow_usercount.vbs" do
  source "ta_imagenow-check_imagenow_usercount.vbs.erb"
  notifies :restart, resources(:service => "SplunkForwarder")
end

template "#{node['splunk']['forwarder_home']}/etc/apps/TA-imagenow/default/inputs.conf" do
  source "ta_imagenow-inputs.conf.erb"
  notifies :restart, resources(:service => "SplunkForwarder")
end
