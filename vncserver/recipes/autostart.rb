#
# Cookbook Name:: vncserver
# Recipe:: autostart
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

# Set the RHEL autostart file
template "/etc/sysconfig/vncservers" do
  source "vncservers.erb"
  variables ({
    :users => node[:vncserver][:users]
  })
  # notifies :restart, resources(:service => servicename)
end

# If user has requested that firefox autolaunch be disabled, deploy a custom Xclients
node['vncserver']['users'].each_with_index do |parameters, index|
  parameters.each_key do |user_name|
    if parameters[user_name]['disablefirefoxlaunch']
      template "/home/#{parameters.keys[0]}/.Xclients" do
        source "dotXclients.erb"
        owner  parameters.keys[0]
        group parameters.keys[0]
        mode  0755
      end
    end
  end
end

# Populate users initial passwords from databag
node['vncserver']['users'].each_with_index do |parameters, index|
  parameters.each_key do |user_name|
    unless File.exists?("/home/#{parameters.keys[0]}/.vnc/passwd")
      userDataBag = data_bag_item('users', parameters.keys[0])
      if userDataBag['vncpassword']
        execute "Stage #{parameters.keys[0]}'s password" do
          command "echo \"#{userDataBag['vncpassword']}\" > #{Chef::Config[:file_cache_path]}/#{parameters.keys[0]}-vnc"
        end
        execute "Stage #{parameters.keys[0]}'s password step 2" do
          command "echo \"#{userDataBag['vncpassword']}\" >> #{Chef::Config[:file_cache_path]}/#{parameters.keys[0]}-vnc"
        end
        execute "Populate #{parameters.keys[0]}'s initial VNC password" do
          command "su -l -c \"vncpasswd <#{Chef::Config[:file_cache_path]}/#{parameters.keys[0]}-vnc >/dev/null 2>/dev/null\" #{parameters.keys[0]}"
        end
        execute "Remove #{parameters.keys[0]}'s staged password" do
          command "rm #{Chef::Config[:file_cache_path]}/#{parameters.keys[0]}-vnc"
        end
      end
    end
  end
end
