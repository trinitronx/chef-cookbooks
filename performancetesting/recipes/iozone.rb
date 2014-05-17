#
# Cookbook Name:: performancetesting
# Recipe:: iozone
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
case node['platform_family']
when "debian"
  package "iozone3"
when "rhel"
  unless File.exists?('/usr/bin/iozone')
    remote_file 'iozone' do
      path "#{Chef::Config[:file_cache_path]}/#{node['performancetesting']['iozone_rpm'].split('/').last}"
      source node['performancetesting']['iozone_rpm']
      checksum node['performancetesting']['iozone_checksum']
    end
    rpm_package "iozone" do
      source node['performancetesting']['iozone_rpm']
    end
  end
end
