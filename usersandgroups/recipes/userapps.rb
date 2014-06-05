#
# Cookbook Name:: usersandgroups
# Recipe:: userapps
#
# Copyright 2013, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Setup run-one ppa for older Ubuntu versions
if node['platform'] == 'ubuntu' and node['platform_version'].to_i < 12
  apt_repository "run-one" do
    uri "http://ppa.launchpad.net/run-one/ppa/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "DC68C79C61E668B4D505C77326FB1781A5163C88"
  end
end

# Packages to install on every system
pkgsAllSystems = ['screen','rsync','ncdu']

# Packages for Debian systems
pkgsDebSystems = ['bash-completion','vim','nano','curl','htop','lsof']

# Packages for Ubuntu systems
pkgsUbuSystems = ['run-one','byobu','bash-completion','vim','nano','curl','htop','lsof','gdisk']

# Packages for RHEL systems
pkgsRHELSystems = ['vim-enhanced']


# Install the packages
pkgsAllSystems.each do |i|
  package i
end
case node['platform']
when 'ubuntu'
  pkgsUbuSystems.each do |i|
    package i
  end
when 'debian'
  pkgsDebSystems.each do |i|
    package i
  end
when 'redhat', 'centos'
  pkgsRHELSystems.each do |i|
    package i
  end
end

if node['platform_family'] == 'rhel' and node['platform_version'].to_i > 5
  package 'gdisk'
end
