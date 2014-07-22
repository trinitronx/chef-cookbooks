#
# Cookbook Name:: zfs_linux
# Recipe:: backblaze4
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

# Install the drivers from source
# http://www.highpoint-tech.com/USA_new/series_r750-Download.htm
include_recipe 'zfs_linux::hold_kernel'
include_recipe 'zfs_linux::build_tools'
unless File.exists?("/lib/modules/#{node['os_version']}/kernel/drivers/scsi/r750.ko") or File.exists?("/lib/modules/#{node['os_version']}/kernel/updates/r750.ko") or File.exists?("/lib/modules/#{node['os_version']}/kernel/drivers/scsi/r750/r750.ko")
  ark "r750_source" do
    url node['zol']['drivers']['r750_source'] 
    checksum node['zol']['drivers']['r750_source_checksum']
    strip_components 2
    path "#{Chef::Config[:file_cache_path]}"
    action :put
  end
  execute 'build_r750_kmod' do
    command 'make'
    cwd "#{Chef::Config[:file_cache_path]}/r750_source/product/r750/linux"
  end
  execute 'install_r750_kmod' do
    command 'make install'
    cwd "#{Chef::Config[:file_cache_path]}/r750_source/product/r750/linux"
  end
end

# Optionally, deploy the web management daemon
if node['zol']['drivers']['r750_management_pkg']
  if node['zol']['drivers']['r750_management_mailsettings']
    remote_file '/etc/hptmailset.dat' do
      source node['zol']['drivers']['r750_management_mailsettings']
      if node['zol']['drivers']['r750_management_mailsettings_checksum']
        checksum node['zol']['drivers']['r750_management_mailsettings_checksum']
      end
      mode "0600"
    end
  end
  remote_file "#{Chef::Config[:file_cache_path]}/#{node['zol']['drivers']['r750_management_pkg'].split('/').last}" do
    source node['zol']['drivers']['r750_management_pkg']
    if node['zol']['drivers']['r750_management_pkg_checksum']
      checksum node['zol']['drivers']['r750_management_pkg_checksum']
    end
  end
  package 'hptsvr-https' do
    source "#{Chef::Config[:file_cache_path]}/#{node['zol']['drivers']['r750_management_pkg'].split('/').last}"
    if node['platform_family'] == 'debian'
      provider Chef::Provider::Package::Dpkg
    else
      provider Chef::Provider::Package::Rpm
    end
  end
  template "/etc/hptcfg" do
    source "hptcfg.erb"
    mode "0644"
  end
  service 'hptdaemon' do
    action [:start, :enable]
  end
end
