#
# Cookbook Name:: cron_attributes
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

if node['os'] == 'linux'
  if node['cron']
    if node['cron']['entries'].kind_of?(Array)
      node['cron']['entries'].each_with_index do |parameters, index|
        parameters.each_key do |fragment_name|
          cron_d parameters.keys[0].to_s do
            minute parameters[fragment_name]['minute'] if parameters[fragment_name]['minute']
            hour parameters[fragment_name]['hour'] if parameters[fragment_name]['hour']
            day parameters[fragment_name]['day'] if parameters[fragment_name]['day']
            month parameters[fragment_name]['month'] if parameters[fragment_name]['month']
            weekday parameters[fragment_name]['weekday'] if parameters[fragment_name]['weekday']
            command parameters[fragment_name]['command'] if parameters[fragment_name]['command']
            user parameters[fragment_name]['user'] if parameters[fragment_name]['user']
            mailto parameters[fragment_name]['mailto'] if parameters[fragment_name]['mailto']
            path parameters[fragment_name]['path'] if parameters[fragment_name]['path']
            home parameters[fragment_name]['home'] if parameters[fragment_name]['home']
            shell parameters[fragment_name]['shell'] if parameters[fragment_name]['shell']
            action parameters[fragment_name]['action'] if parameters[fragment_name]['action']
          end
        end
      end
    end
  end
end
