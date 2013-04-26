#
# Cookbook Name:: vmware
# Recipe:: perlsdk
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


src_filename = node['vmware']['perlsdk_x64_url'].split('/').last
src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"
extract_path = "#{Chef::Config['file_cache_path']}/" + src_filename.split('.').first


if (node['kernel']['machine'] == "x86_64") && (not File.exists?("/usr/bin/vmware-uninstall-vSphere-CLI.pl"))
  remote_file src_filepath do
    source node['vmware']['perlsdk_x64_url']
    checksum node['vmware']['perlsdk_x64_checksum']
  end

  bash 'extract_installer' do
    cwd ::File.dirname(src_filepath)
    code <<-EOH
      mkdir -p #{extract_path}
      tar xzf #{src_filename} -C #{extract_path}
      EOH
    not_if { ::File.exists?(extract_path) }
  end

  bash 'execute_installer' do
    cwd extract_path + "/vmware-vsphere-cli-distrib"
    code <<-EOH
      ./vmware-install.pl -d
      EOH
  end
end


