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

# Determine if the tasks exists (compatible with Windows 2003)
def task_exists(task_name)
  value = true
  # Windows 2008+
  if node["platform_version"] >= "6"
    output = `schtasks /Query /TN "#{task_name}" 2> NUL | find /c \"#{task_name}\"`
    value = (output.chomp == "0") ? false : true;
  # Windows 2003
  else
    value = (::File.exist?("#{ENV['windir']}/Tasks/#{task_name}.job")) ? true : false;   
  end
  value
end

if node['windows']
  if node['windows']['scheduled_tasks']
    node['windows']['scheduled_tasks'].each_with_index do |parameters, index|
      parameters.each_key do |task_name|
        # Set the default action to create
        task_action = parameters[task_name]['action'].nil? ? 'create' : parameters[task_name]['action']

        if (((task_action == 'create' || task_action == 'run') && !task_exists(task_name)) || (task_action == 'delete' && task_exists(task_name)))
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
    end
  end
end