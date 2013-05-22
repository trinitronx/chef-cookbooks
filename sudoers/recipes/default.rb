#
# Cookbook Name:: sudoers
# Recipe:: default
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

if node['authorization']['sudo']['include_sudoers_d']
  node['authorization']['sudoers'].each_with_index do |parameters, index|
    parameters.each_key do |fragment_name|
      sudo parameters.keys[0].to_s do
        user parameters[fragment_name]['user'] if parameters[fragment_name]['user']
        group parameters[fragment_name]['group'] if parameters[fragment_name]['group']
        commands parameters[fragment_name]['commands'] if parameters[fragment_name]['commands']
        host parameters[fragment_name]['host'] if parameters[fragment_name]['host']
        runas parameters[fragment_name]['runas'] if parameters[fragment_name]['runas']
        nopasswd parameters[fragment_name]['nopasswd'] if parameters[fragment_name]['nopasswd']
      end
    end
  end
end