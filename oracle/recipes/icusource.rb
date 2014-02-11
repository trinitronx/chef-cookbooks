#
# Cookbook Name:: oracle
# Recipe:: icasource
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

include_recipe "oracle::icu"

case node['platform_family']
when "rhel"
  directory "/usr/src/redhat"
  unless File.directory? ('/usr/local/src/icu')
    require 'chef/shell_out'
    
    cmd = Chef::ShellOut.new("yum info libicu | grep Release | tail -n1 | sed 's/Release    : //g'")
    output = cmd.run_command
    icurel = output.stdout.strip
    
    cmd = Chef::ShellOut.new("yum info libicu | grep Version | tail -n1 | sed 's/Version    : //g'")
    output = cmd.run_command
    icuver = output.stdout.strip
    
    ftpurl = "ftp://ftp.redhat.com/pub/redhat/linux/enterprise/#{node['platform_version'].to_f.floor.to_s}Server/en/os/SRPMS/icu-#{icuver}-#{icurel}.src.rpm".strip
    
    remote_file "#{Chef::Config[:file_cache_path]}/icu-#{icuver}-#{icurel}.src.rpm" do
      source ftpurl
    end
    
    rpm_package "icu" do
      source "#{Chef::Config[:file_cache_path]}/icu-#{icuver}-#{icurel}.src.rpm"
      action :install
    end
    
    bash 'icu_extract' do
      cwd "/usr/local/src"
      code <<-EOH
        tar xzf /usr/src/redhat/SOURCES/icu4c-#{icuver.sub(".","_")}-src.tgz
        chown -R root:root icu
        EOH
    end
    
  end
  
end
