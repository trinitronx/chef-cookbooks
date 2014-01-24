#
# Cookbook Name:: usersandgroups
# Recipe:: default
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

if node['usersandgroups']

  include_recipe "users::default"

  chef_gem "ruby-shadow"
  require "etc"

  existing_node_users = []
  Etc.passwd {|u|
    existing_node_users << u.name
  }
  
  existing_node_groups = []
  Etc.group {|g|
    existing_node_groups << g.name
  }


  # First, set up any needed groups
  if node['usersandgroups']['groups']
     node['usersandgroups']['groups'].each do |groupname|
       groupname.each do |gkey, gvalue|
         # First, see if an environment is set. If so, only operate in that environment
         if !gvalue['environment'] || ( gvalue['environment'] == node['environment'] if gvalue['environment'] )
           # Specifying an id makes it a non-system group
           if gvalue['gid']
             # create_only flag availble for bypassing the users_manage lwrp
             unless gvalue['create_only']
               users_manage gkey.to_s do
                 group_id gvalue['gid'].to_i
                 action [ :remove, :create ]
                 if gvalue['group_name']
                   group_name gvalue['group_name']
                 end
               end
             else
               group gkey.to_s do
                 gid gvalue['gid'].to_i
               end
             end
           else
             unless existing_node_groups.include?(gkey.to_s)
               group gkey.to_s do
                 system true
               end
             end
           end
         end
       end
     end
  end

  # Now continue with system account creation
  if node['usersandgroups']['users']

    node['usersandgroups']['users'].each do |username|
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
        if uvalue['delete_user'] or ( userdatab['delete_user'] if userdatab )
          user ukey.to_s do
            action :remove
          end
        else
          # Set home to location in data bag,
          # or a reasonable default (/home/$user).
          if uvalue['home'] || ( userdatab['home'] if userdatab )
            home_dir = uvalue['home'] || ( userdatab['home'] if userdatab )
          else
            home_dir = "/home/#{ukey.to_s}"
          end
          # Create the user if the 'create_if_missing' attribute is set
          # and change the user's password no matter what
          if uvalue['create_if_missing']
            unless existing_node_users.include?(ukey.to_s)
              user ukey.to_s do
                unless uvalue['uid'] or ( userdatab['uid'] if userdatab )
                  system true
                  unless uvalue['home'] or ( userdatab['home'] if userdatab )
                    home "/"
                  else
                    unless uvalue['disable_manage_home'] or ( userdatab['disable_manage_home'] if userdatab )
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
                if uvalue['shell'] or ( userdatab['shell'] if userdatab )
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
                unless uvalue['disable_manage_home'] or ( userdatab['disable_manage_home'] if userdatab )
                  manage_home true
                end
              end
              existing_node_users << ukey.to_s
            else
              if uvalue['password'] or ( userdatab['password'] if userdatab )
                user ukey.to_s do
                  action :manage
                  password uvalue['password'] || userdatab['password']
                end
              end
            end
          else
            # Since create_is_missing isn't set, manage the user's password only)
            if existing_node_users.include?(ukey.to_s)
              if uvalue['password'] or ( userdatab['password'] if userdatab )
                user ukey.to_s do
                  action :manage
                  password uvalue['password'] || userdatab['password']
                end
              end
            end
          end
          # Set up the user's ssh keys if the user exists
          # and they have keys specified
          if existing_node_users.include?(ukey.to_s)
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
