#
# Cookbook Name:: directory_management
# Recipe:: nfs_client 
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

include_recipe "nfs::default"

# First, check attributes for mounts to remove
if node['nfs']['mounts_to_remove']  != nil 
  node['nfs']['mounts_to_remove'].each_pair do |path,config| 
    mount path.to_s do
      action [:umount, :disable]
      ignore_failure true
    end    
  end
end


# Read the attributes for the node's specified mount points and create the appropriate directory
node['nfs']['mounts'].each_pair do |path,config|
  directory path do
    action :create
  end
  mount path.to_s do
    device config['device']
    fstype config['fstype']
    options config['options'] if config['options']
    action [:mount, :enable] if config['fstab'] == true
  end    
end
