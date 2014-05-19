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

case node['platform']
when "centos"
  if node['platform_version'] == "6.3"
    # Binary drivers for the Rocket 750 cards are available for install
    # http://www.highpoint-tech.com/USA_new/series_r750-Download.htm
    unless File.exists?("/lib/modules/#{node['os_version']}/kernel/drivers/scsi/r750.ko") or File.exists?("/lib/modules/#{node['os_version']}/kernel/updates/r750.ko")
      ark "r750-centos-63" do
        url node['zol']['drivers']['r750_centos_63'] 
        checksum node['zol']['drivers']['r750_centos_63_checksum']
        strip_components 0
        path "#{Chef::Config[:file_cache_path]}"
        action :put
      end
      execute 'install_r750_kmod' do
        command "#{Chef::Config[:file_cache_path]}/r750-centos-63/install.sh"
        cwd "#{Chef::Config[:file_cache_path]}/r750-centos-63"
      end
    end
    
    # Quick workound option for adding legacy header packages when the
    # kernel version is pinned
    if node['zol']['drivers']['centos_63']['custom_header_pkg']
      remote_file node['zol']['drivers']['centos_63']['custom_header_pkg'].split('/').last do
        path "#{Chef::Config[:file_cache_path]}/#{node['zol']['drivers']['centos_63']['custom_header_pkg'].split('/').last}"
        source node['zol']['drivers']['centos_63']['custom_header_pkg'] 
        checksum node['zol']['drivers']['centos_63']['custom_header_checksum'] 
      end
      remote_file node['zol']['drivers']['centos_63']['custom_devel_pkg'].split('/').last do
        path "#{Chef::Config[:file_cache_path]}/#{node['zol']['drivers']['centos_63']['custom_devel_pkg'].split('/').last}"
        source node['zol']['drivers']['centos_63']['custom_devel_pkg'] 
        checksum node['zol']['drivers']['centos_63']['custom_devel_checksum'] 
      end
      package "kernel-headers" do
        source "#{Chef::Config[:file_cache_path]}/#{node['zol']['drivers']['centos_63']['custom_header_pkg'].split('/').last}"
        provider Chef::Provider::Package::Rpm
      end
      package "kernel-devel" do
        source "#{Chef::Config[:file_cache_path]}/#{node['zol']['drivers']['centos_63']['custom_devel_pkg'].split('/').last}"
        provider Chef::Provider::Package::Rpm
      end
    end
  end
end
