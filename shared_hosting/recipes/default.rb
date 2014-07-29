#
# Cookbook Name:: shared_hosting
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

# Service definitions
service "ssh" do
  supports :restart => true
  action :nothing
end

# Install the acl package and re-mount the /srv partition with acl support
package "acl" do
  notifies :disable, "mount[srv]", :immediately
  notifies :enable, "mount[srv]", :immediately
  notifies :run, "execute[remount-srv]", :immediately
end

mount "srv" do
  mount_point "/srv"
  device "/dev/mapper/VolGroup1-LogVolSrv"
  fstype "ext4"
  options "defaults,acl"
  action :nothing
end

execute "remount-srv" do
  command "mount -o remount /srv"
  action :nothing
end

# Create a group for users that need to be chrooted when using SFTP
group node['shared_hosting']['chroot_group'] do
  action :create
  not_if "getent group | grep #{node['shared_hosting']['chroot_group'].downcase}"
end

# Configure openssh to chroot users in the group specified in the ['shared_hosting']['chroot_group'] attribute
template "/etc/ssh/sshd_config" do
  owner "root"
  group "root"
  mode 00644
  source "sshd_config.erb"
  variables(
    :chroot_group => node['shared_hosting']['chroot_group'].downcase
  )
  notifies :restart, "service[ssh]"
end