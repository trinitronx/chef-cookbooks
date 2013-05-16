#
# Cookbook Name:: windows_tasks
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

node['windows']['scheduled_tasks'].each_with_index do |parameters, index|
  parameters.each_key do |task_name|
    windows_task parameters.keys[0].to_s do
      user parameters[task_name]['user'] if parameters[task_name]['user']
      password parameters[task_name]['password'] if parameters[task_name]['password']
      cwd parameters[task_name]['cwd'] if parameters[task_name]['cwd']
      command parameters[task_name]['command'] if parameters[task_name]['command']
      action parameters[task_name]['action'].to_sym if parameters[task_name]['action']
      run_level parameters[task_name]['run_level'].to_sym if parameters[task_name]['run_level']
      frequency parameters[task_name]['frequency'].to_sym if parameters[task_name]['frequency']
      frequency_modifier parameters[task_name]['frequency_modifier'] if parameters[task_name]['frequency_modifier']
      start_day parameters[task_name]['start_day'] if parameters[task_name]['start_day']
      start_time parameters[task_name]['start_time'] if parameters[task_name]['start_time']
    end
  end
end
