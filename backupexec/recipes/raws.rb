#
# Cookbook Name:: backupexec
# Recipe:: raws
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

# Need to ensure it's pulled in for the lwrps
include_recipe "windows"

if node["kernel"]["os_info"]["os_architecture"] == "64-bit"
  unless File.exist?("C:/Program Files/Symantec/Backup Exec/RAWS/beremote.exe")

    directory "#{Chef::Config[:file_cache_path]}/raws"

    windows_zipfile "#{Chef::Config[:file_cache_path]}/raws" do
      source node['backupexec']['rawsx64url']
      action :unzip
    end 

    windows_batch "install_backupexec_raws" do
      cwd "#{Chef::Config[:file_cache_path]}/raws"
      code <<-EOH
      setupaax64.cmd
      EOH
    end

  end
else
  unless File.exist?("C:/Program Files/Symantec/Backup Exec/RAWS/beremote.exe")

    directory "#{Chef::Config[:file_cache_path]}/raws"

    windows_zipfile "#{Chef::Config[:file_cache_path]}/raws" do
      source node['backupexec']['raws32url']
      action :unzip
    end 

    windows_batch "install_backupexec_raws" do
      cwd "#{Chef::Config[:file_cache_path]}/raws"
      code <<-EOH
      Setupaa.cmd
      EOH
    end

  end

end

