#
# Cookbook Name:: windows_software
# Recipe:: nmap
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

if node['platform'] == "windows" then
  include_recipe "windows::default"
  windows_package node['windows_software']['nmap']['displayname'] do
    source node['windows_software']['nmap']['download_url']
    checksum node['windows_software']['nmap']['checksum']
    installer_type :custom
    options '/S'
    action :install
  end
end
