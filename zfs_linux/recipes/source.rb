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

# Setup pre-reqs
include_recipe 'zfs_linux::hold_kernel'
include_recipe 'zfs_linux::build_tools'

# Perform the installation
case node['platform_family']
when "rhel"
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
    command "#{Chef::Config[:file_cache_path]}/spl/configure --with-config=user"
    cwd "#{Chef::Config[:file_cache_path]}/spl"
    action :nothing
    notifies :run, "execute[build_spl]"
  end
  
  execute 'build_spl' do
    command 'make rpm-utils rpm-dkms'
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
    command "#{Chef::Config[:file_cache_path]}/zfs/configure --with-config=user"
    cwd "#{Chef::Config[:file_cache_path]}/zfs"
    action :nothing
    notifies :run, "execute[build_zfs]"
  end
  
  execute 'build_zfs' do
    command "make rpm-utils rpm-dkms"
    cwd "#{Chef::Config[:file_cache_path]}/zfs"
    action :nothing
    notifies :run, "execute[install_zfs]"
  end
  
  execute 'install_zfs' do
    command 'yum install -y spl/spl-[0-9]*x86_64.rpm spl/spl-dkms-*noarch.rpm zfs/zfs-[0-9]*.x86_64.rpm zfs/zfs-dkms-*.noarch.rpm zfs/zfs-dracut-*.x86_64.rpm zfs/zfs-test*.x86_64.rpm'
    cwd "#{Chef::Config[:file_cache_path]}"
    action :nothing
  end


when "debian"
  if node['platform_version'].to_f >= 12.04
    
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
    end
    
    package "mountall" do
      source "#{Chef::Config[:file_cache_path]}/#{node['zol']['mountall_url'].split('/').last}"
      provider Chef::Provider::Package::Dpkg
    end
    
    execute "echo mountall hold | dpkg --set-selections" do
      not_if "dpkg --get-selections | grep '^mountall' | grep -q 'hold'"
    end
  end
end
