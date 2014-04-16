#
# Cookbook Name:: directory_management
# Recipe:: win_shares
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

if node['windows']
  if node['windows']['shares']
    # Read the attributes for the node's specified shares and create them
    node['windows']['shares'].each_pair do |share,config|
      # Check for the existence of the share first
      cmd = Mixlib::ShellOut.new("net view \\\\#{node.name}")
      cmd.run_command
      unless cmd.stdout.include?(share)
        # Setup grants
        grants = ''
        config['grants'].each_pair do |grantee,perms|
          grants << " /GRANT:\"#{grantee}\",#{perms}"
        end
        execute "net share \"#{share}=#{config['path']}\"#{grants}"
      end
    end
  end
end
