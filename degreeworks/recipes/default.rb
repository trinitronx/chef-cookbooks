#
# Cookbook Name:: degreeworks
# Recipe:: default
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

# sharutils is now in the optional channel; enabling it
# if necessary
if node['platform_version'].split('.')[0].to_i > 5
  include_recipe 'rhn::optionalchannel'
end

# General dependencies
if node['os'] == 'linux'
  ['gcc', 'autoconf', 'automake', 'sharutils', 'ncurses-devel', 'openssl', 'openssl-devel', 'openldap-clients', 'httpd', 'mod_ssl'].each do |pkg|
    package pkg
  end
  # openssl-static doesn't appear to be available or necessary before RHEL 6
  if node['platform_version'].split('.')[0].to_i > 5
    package 'openssl-static'
  end
end

# FOP
directory node['degreeworks']['thirdpartyjavadir'] do
  owner node['degreeworks']['adminuser']
  action :create
  recursive true
end
# Dynamically create directory fop-x.x
ark node['degreeworks']['fopurl'].split('/').last.split('-bin').first do
  url node['degreeworks']['fopurl']
  checksum node['degreeworks']['fopchecksum']
  action :put
  path node['degreeworks']['thirdpartyjavadir']
  owner node['degreeworks']['adminuser']
end

# Required directory
directory '/opt/steno' do
  owner node['degreeworks']['adminuser']
  action :create
  recursive true
end
