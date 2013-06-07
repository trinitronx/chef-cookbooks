#
# Cookbook Name:: users
# Recipe:: useraccounts
#
# Copyright 2013, Biola University
# Copyright 2011, Eric G. Wolfe
# Copyright 2009-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

chef_gem "ruby-shadow"
require "etc"

existing_system_users = []
Etc.passwd {|u|
  existing_system_users << u.name
}

existing_system_groups = []
Etc.group {|g|
  existing_system_groups << g.name
}

if node['users']

# First, set up any needed system groups
  if node['users']['systemgroups']
     node['users']['systemgroups'].each do |groupname|
       groupname.each do |gkey, gvalue|
         unless existing_system_groups.include?(gkey.to_s)
           group gkey.to_s do
             system true
           end
         end
       end
     end
  end

  # Now continue with system account creation
  if node['users']['systemaccounts']

    node['users']['systemaccounts'].each do |username|
      username.each do |ukey, uvalue|

        unless uvalue['ignore_databag']
          if uvalue['databagname']
            userdatab = data_bag_item('users', uvalue['databagname'])
          else
            userdatab = data_bag_item('users', ukey.to_s)
          end
        else
          userdatab = nil
        end
  
        # If the user is set to delete, only do that
        if uvalue['deleteuser'] or ( userdatab['deleteuser'] if userdatab )
          user ukey.to_s do
            action :remove
          end
        else
          # Set home to location in data bag,
          # or a reasonable default (/home/$user).
          if uvalue['home'] || userdatab['home']
            home_dir = uvalue['home'] || userdatab['home']
          else
            home_dir = "/home/#{ukey.to_s}"
          end
          # Create the user if the 'createifmissing' attribute is set
          # and change the user's password no matter what
          if uvalue['createifmissing']
            unless existing_system_users.include?(ukey.to_s)
              user ukey.to_s do
                unless uvalue['uid'] or ( userdatab['uid'] if userdatab )
                  system true
                  unless uvalue['home'] or ( userdatab['home'] if userdatab )
                    home "/"
                  else
                    unless uvalue['dont_manage_home'] or ( userdatab['dont_manage_home'] if userdatab )
                      manage_home true
                    end
                    home home_dir
                  end
                  if uvalue['gid'] or ( userdatab['gid'] if userdatab )
                    gid uvalue['gid'] || userdatab['gid']
                  end
                else
                  uid uvalue['uid'] || userdatab['uid']
                  home home_dir
                end
                if uvalue['uid'] or ( userdatab['shell'] if userdatab )
                  shell uvalue['shell'] || userdatab['shell']
                else
                  shell "/bin/bash"
                end
                if uvalue['password'] or ( userdatab['password'] if userdatab )
                  password uvalue['password'] || userdatab['password']
                end
                if uvalue['comment'] or ( userdatab['comment'] if userdatab )
                  comment uvalue['comment'] || userdatab['comment']
                end
                if uvalue['gid'] or ( userdatab['gid'] if userdatab )
                  gid uvalue['gid'] || userdatab['gid']
                end
                unless uvalue['dont_manage_home'] or ( userdatab['dont_manage_home'] if userdatab )
                  manage_home true
                end
              end
              existing_system_users << ukey.to_s
            else
              if uvalue['password'] or ( userdatab['password'] if userdatab )
                user ukey.to_s do
                  action :manage
                  password uvalue['password'] || userdatab['password']
                end
              end
            end
          else
            if uvalue['password'] or ( userdatab['password'] if userdatab )
              user ukey.to_s do
                action :manage
                password uvalue['password'] || userdatab['password']
              end
            end
          end
          # Set up the user's ssh keys if the user exists
          # and they have keys specified
          if existing_system_users.include?(ukey.to_s)
            if userdatab
              if userdatab['ssh_keys'] or userdatab['ssh_private_key'] or userdatab['ssh_public_key']
                directory "#{home_dir}/.ssh" do
                  mode 0700
                  owner ukey.to_s
                  group userdatab['gid'] || ukey.to_s
                end
              end
              if userdatab['ssh_keys']
                template "#{home_dir}/.ssh/authorized_keys" do
                  source "authorized_keys.erb"
                  #cookbook new_resource.cookbook
                  owner ukey.to_s
                  group userdatab['gid'] || ukey.to_s
                  mode "0600"
                  variables :ssh_keys => userdatab['ssh_keys']
                end
              end
              if userdatab['ssh_private_key']
                key_type = userdatab['ssh_private_key'].include?("BEGIN RSA PRIVATE KEY") ? "rsa" : "dsa"
                template "#{home_dir}/.ssh/id_#{key_type}" do
                  source "private_key.erb"
                  #cookbook new_resource.cookbook
                  owner ukey.to_s
                  group userdatab['gid'] || ukey.to_s
                  mode "0400"
                  variables :private_key => userdatab['ssh_private_key']
                end
              end
              if userdatab['ssh_public_key']
                key_type = userdatab['ssh_public_key'].include?("ssh-rsa") ? "rsa" : "dsa"
                template "#{home_dir}/.ssh/id_#{key_type}.pub" do
                  source "public_key.pub.erb"
                  #cookbook new_resource.cookbook
                  owner ukey.to_s
                  group userdatab['gid'] || ukey.to_s
                  mode "0400"
                  variables :public_key => userdatab['ssh_public_key']
                end
              end
            end
          end
        end
      end
    end
  end
end
