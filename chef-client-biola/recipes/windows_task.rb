#
# Cookbook Name:: chef-client-biola
# Recipe:: windows_task
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

if node["platform"] == "windows"
	# Remove the chef-client service if it exists
	unless WMI::Win32_Service.find(:first, :conditions => {:name => "chef-client"}).nil?
		service "chef-client" do
			action [ :disable, :stop ]
		end

		execute "uninstall service" do
			command "sc delete chef-client"
			action :run
		end
	end

	# Scheduled task options
	task_name = "chef-client"
	task_command = "#{node["chef_client"]["ruby_bin"]} #{node["chef_client"]["bin"]} -L #{File.join(node["chef_client"]["log_dir"], "client.log")} -c #{File.join(node["chef_client"]["conf_dir"], "client.rb")} -s #{node["chef_client"]["splay"]}"
	task_interval = node["chef_client"]["interval"].to_i / 60

	# Windows 2008+
	if node["platform_version"] >= "6"
		# Check for an existing scheduled task
		output = `schtasks /Query /TN "#{task_name}" 2> NUL | find /c \"#{task_name}\"`
		# If the task doesn't exist, create it
		if output.chomp == "0"
			execute "create scheduled task" do
				command "schtasks /Create /TN \"#{task_name}\" /SC minute /MO #{task_interval} /TR \"#{task_command}\" /RU \"SYSTEM\" /RL HIGHEST"
				action :run
			end
		end
	# Windows 2003
	else
		# Check for an existing scheduled task
		unless ::File.exist?("#{ENV['windir']}/Tasks/#{task_name}.job")
			execute "create scheduled task" do
				command "schtasks /Create /TN \"#{task_name}\" /SC minute /MO #{task_interval} /TR \"#{task_command}\" /RU \"SYSTEM\""
				action :run
			end			
		end
	end
end