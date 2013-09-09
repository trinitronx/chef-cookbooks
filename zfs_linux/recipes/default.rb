#
# Cookbook Name:: zfs_linux
# Recipe:: default
#
# Copyright 2013, Biola University 
# Copyright (c) 2012, Cameron Johnston
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

case node['platform']
when "ubuntu"
  if node['platform_version'].to_f >= 10.04
 
    include_recipe "apt"
 
    apt_repository "zfs-native" do
      uri "http://ppa.launchpad.net/zfs-native/stable/ubuntu"
      distribution node['lsb']['codename']
      components ['main']
      keyserver "keyserver.ubuntu.com"
      key "F6B0FC61"
      action :add
    end

    package "ubuntu-zfs"
    
  end
end

# This will only be relevant for nodes with the appropriate
# attributes set, so it should be pretty safe to always have it run
include_recipe "zfs_linux::snapshot-pruning"
