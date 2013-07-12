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
        directory "/home/#{parameters.keys[0]}/.vnc" do
          owner parameters.keys[0]
          group parameters.keys[0]
        end
        execute "Populate #{parameters.keys[0]}'s initial VNC password" do
          command "su -l -c 'echo #{userDataBag['vncpassword']}|vncpasswd -f > /home/#{parameters.keys[0]}/.vnc/passwd' #{parameters.keys[0]}"
        end
        file "/home/#{parameters.keys[0]}/.vnc/passwd" do
          owner parameters.keys[0]
          group parameters.keys[0]
          mode 0600
        end
      end
    end
  end
end
