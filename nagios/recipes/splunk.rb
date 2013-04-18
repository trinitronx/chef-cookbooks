#
# Cookbook Name:: splunk_windows
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

# Assign default attributes for Splunk inputs to node
node.default["splunk"]["monitors"] = [
	"nagios_log" => {"location" => node['nagios']['log_dir'] + "nagios.log", "index" => "nagios"},
	"host_perfdata" => {"location" => node['nagios']['log_dir'] + "host-perfdata", "index" => "nagios"},
	"service_perfdata" => {"location" => node['nagios']['log_dir'] + "service-perfdata", "index" => "nagios"},
]

# Install the MK Livestatus plugin if using a Debian-based system
if node['platform_family'] == 'debian'
	%w{ 
	  xinetd
	  check-mk-livestatus
	}.each do |pkg|
	  package pkg
	end

  # determine hosts that NRPE will allow monitoring from
  mon_host = ['127.0.0.1']

  # put all nagios servers that you find in the NPRE config.
  if node['nagios']['multi_environment_monitoring']
    search(:node, "role:#{node['nagios']['server_role']}") do |n|
      mon_host << n['ipaddress']
    end
  else
    search(:node, "role:#{node['nagios']['server_role']} AND chef_environment:#{node.chef_environment}") do |n|
      mon_host << n['ipaddress']
    end
  end
  # on the first run, search isn't available, so if you're the nagios server, go
  # ahead and put your own IP address in the NRPE config (unless it's already there).
  if node.run_list.roles.include?(node['nagios']['server_role'])
    unless mon_host.include?(node['ipaddress'])
      mon_host << node['ipaddress']
    end
  end

	# Set up a xinetd livestatus service
	template "/etc/xinetd.d/livestatus" do
    source "livestatus.erb"
    variables(
      :mon_host => mon_host
    )
  end

  # Restart the xinetd service
  service "xinetd" do
    action :restart
  end
end