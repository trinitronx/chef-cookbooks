#
# Cookbook Name:: zfs_linux
# Recipe:: source
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
when "ubuntu"
  if node['platform_version'].to_f >= 12.04
    prereqpkgs = ['build-essential', 'gawk', 'alien', 'fakeroot', 'zlib1g-dev', 'uuid-dev', 'libblkid-dev', 'libselinux-dev', 'parted', 'lsscsi', 'wget', 'automake', 'libtool', 'git']
    # Find the version of the current kernel
    krnvercmd = Mixlib::ShellOut.new('uname -r')
    krnvercmd.run_command
    krnver = krnvercmd.stdout.chomp
    # Compiled modules will be build against and installed to specific kernels
    # Hold the kernel packages here accordingly
    if node['platform_version'] == '12.04'
      kernelpkgs = ['linux-server', 'linux-image-server']
      prereqpkgs << 'linux-headers-server'
    else
      kernelpkgs = ['linux-generic', 'linux-image-generic']
      prereqpkgs << 'linux-headers-generic'
    end
    kernelpkgs.each do |kernelpkg|
      execute "echo #{kernelpkg} hold | dpkg --set-selections" do
        not_if "dpkg --get-selections | grep '^#{kernelpkg}' | grep -q 'hold'"
      end
    end
    
    # Install pre-reqs
    prereqpkgs.each do |pkg|
      package pkg
    end
    
    # linux-headers package could depend on a newer version of this package;
    # explicity install the version for the current kernel just in case
    unless File.directory?("/usr/src/linux-headers-#{krnver}")
      package "linux-headers-#{krnver}"
    end
    
    # This will start the chain of download/compilation
    # So it's always possible to start over by deleting
    # /var/chef/cache/spl & /var/chef/cache/zfs
    git "#{Chef::Config[:file_cache_path]}/spl" do
      repository node['zol']['spl_repo']
      revision node['zol']['spl_commit']
      notifies :run, "execute[autogen_spl]"
    end
    
    execute 'autogen_spl' do
      command "#{Chef::Config[:file_cache_path]}/spl/autogen.sh"
      cwd "#{Chef::Config[:file_cache_path]}/spl"
      action :nothing
      notifies :run, "execute[configure_spl]"
    end
    
    execute 'configure_spl' do
      command "#{Chef::Config[:file_cache_path]}/spl/configure"
      cwd "#{Chef::Config[:file_cache_path]}/spl"
      action :nothing
      notifies :run, "execute[build_spl]"
    end
    
    execute 'build_spl' do
      command 'make deb-utils deb-kmod'
      cwd "#{Chef::Config[:file_cache_path]}/spl"
      action :nothing
      notifies :run, "execute[install_spl_devel]"
    end
    
    # This will install the two development packages needed for zfs
    # compilation
    execute 'install_spl_devel' do
      command 'dpkg -i ./kmod-spl-devel*'
      cwd "#{Chef::Config[:file_cache_path]}/spl"
      action :nothing
      notifies :sync, "git[#{Chef::Config[:file_cache_path]}/zfs]"
    end
    
    git "#{Chef::Config[:file_cache_path]}/zfs" do
      repository node['zol']['zfs_repo']
      revision node['zol']['zfs_commit']
      notifies :run, "execute[autogen_zfs]"
      action :nothing
    end
    
    execute 'autogen_zfs' do
      command "#{Chef::Config[:file_cache_path]}/zfs/autogen.sh"
      cwd "#{Chef::Config[:file_cache_path]}/zfs"
      action :nothing
      notifies :run, "execute[configure_zfs]"
    end
    
    execute 'configure_zfs' do
      command "#{Chef::Config[:file_cache_path]}/zfs/configure"
      cwd "#{Chef::Config[:file_cache_path]}/zfs"
      action :nothing
      notifies :run, "execute[build_zfs]"
    end
    
    execute 'build_zfs' do
      command "make deb-utils deb-kmod"
      cwd "#{Chef::Config[:file_cache_path]}/zfs"
      action :nothing
      notifies :run, "execute[install_zfs]"
    end
    
    execute 'install_zfs' do
      command 'dpkg -i spl/*.deb zfs/*.deb'
      cwd "#{Chef::Config[:file_cache_path]}"
      action :nothing
      notifies :create, "remote_file[mountall]"
    end
    
    # Custom mountall package needed to auto-mount zfs volumes
    # at boot
    remote_file 'mountall' do
      path "#{Chef::Config[:file_cache_path]}/#{node['zol']['mountall_url'].split('/').last}"
      source node['zol']['mountall_url'] 
      checksum node['zol']['mountall_checksum'] 
      #action :nothing
      #notifies :install, "package[mountall]"
    end
    
    package "mountall" do
      #action :nothing
      source "#{Chef::Config[:file_cache_path]}/#{node['zol']['mountall_url'].split('/').last}"
      provider Chef::Provider::Package::Dpkg
      #notifies :run, "execute[echo mountall hold | dpkg --set-selections]"
    end
    
    execute "echo mountall hold | dpkg --set-selections" do
      #action :nothing
      not_if "dpkg --get-selections | grep '^mountall' | grep -q 'hold'"
    end
  end
end
