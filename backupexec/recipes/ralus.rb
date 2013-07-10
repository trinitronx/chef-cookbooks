#
# Cookbook Name:: backupexec
# Recipe:: ralus
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

# Set up ralus service
service "VRTSralus.init" do
  supports :start => true, :restart => true, :stop => true
end

# Required GCC dependency of RALUS
# For Ubuntu 10.04, not available in standard repository
if node[:platform_version] == "10.04"
  if node[:kernel][:machine] == "x86_64"
	cookbook_file "#{Chef::Config[:file_cache_path]}/libstdc++5_3.3.6-20~lucid1_amd64.deb" do
		source "libstdc++5_3.3.6-20~lucid1_amd64.deb"
		action :create_if_missing
		not_if "test -f /usr/lib/libstdc++.so.5"
	end
	dpkg_package "libstdc++5" do
		action :install
		source "#{Chef::Config[:file_cache_path]}/libstdc++5_3.3.6-20~lucid1_amd64.deb"
		not_if "test -f /usr/lib/libstdc++.so.5"	
	end
  end
  if node[:kernel][:machine] == "i686"
	cookbook_file "#{Chef::Config[:file_cache_path]}/libstdc++5_3.3.6-20~lucid1_i386.deb" do
		source "libstdc++5_3.3.6-20~lucid1_amd64.deb"
		action :create_if_missing
		not_if "test -f /usr/lib/libstdc++.so.5"
	end
	dpkg_package "libstdc++5" do
		action :install
		source "#{Chef::Config[:file_cache_path]}/libstdc++5_3.3.6-20~lucid1_i386.deb"
		not_if "test -f /usr/lib/libstdc++.so.5"	
	end
  end

else 
package "libstdc++5" do
  action :install
  end
end

# System needs beoper group, and root must be a member
group "beoper" do
  action :create
  append true
  members "root"
end

cookbook_file "#{Chef::Config[:file_cache_path]}/RALUS.tar.gz" do
  source "RALUS.tar.gz"
  action :create_if_missing
  not_if "test -f /opt/VRTSralus/bin/beremote"
  end


# Response file pulled from /var/tmp/vxif after installation
# Deleted systems line from the file
template "#{Chef::Config[:file_cache_path]}/ralusresponsefile.response" do
  source "ralusresponsefile.response.erb"
  not_if "test -f /opt/VRTSralus/bin/beremote"
  end

# Install steps 
execute "ExtractRALUSinstaller" do
	command "tar -zxf " + Chef::Config[:file_cache_path] + "/RALUS.tar.gz"
	cwd Chef::Config[:file_cache_path]
	creates Chef::Config[:file_cache_path] + "/installralus"
end

execute "ExtractRALUSinstaller" do
	command "./installralus -forcelocal -responsefile " + Chef::Config[:file_cache_path] + "/ralusresponsefile.response"
	cwd Chef::Config[:file_cache_path]
	creates "/opt/VRTSralus/bin/beremote"
	returns [0,1]
	notifies :restart, "service[VRTSralus.init]"
end


