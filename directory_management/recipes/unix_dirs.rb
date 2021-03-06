#
# Cookbook Name:: directory_management
# Recipe:: unix_dirs
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

if node['directories']
  node['directories'].each do |dirhash|
    dirhash.each_pair do |key,value|
      directory key do
        if value['owner']
          owner value['owner']
        end
        if value['group']
          owner value['group']
        end
        if value['mode']
          owner value['mode']
        end
      end
      # The directory resource will not enforce directory permissions on existing directories
      # So, we'll manually apply those here
      if value['owner'] and value['group']
        execute "chown #{value['owner']}:#{value['group']} #{key}"
      end
      if value['mode']
        execute "chmod #{value['mode']} #{key}"
      end
    end
  end
end
