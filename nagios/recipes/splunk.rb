#
# Cookbook Name:: nagios
# Recipe:: splunk
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
	"nagios_log" => {"location" => node['nagios']['log_dir'] + "/nagios.log", "index" => "nagios", "sourcetype" => "nagios"},
	"host_perfdata" => {"location" => node['nagios']['log_dir'] + "/host-perfdata", "index" => "nagios", "sourcetype" => "nagioshostperf"},
	"service_perfdata" => {"location" => node['nagios']['log_dir'] + "/service-perfdata", "index" => "nagios", "sourcetype" => "nagiosserviceperf"},
]

# Install the MK Livestatus plugin if using a Debian-based system
if node['platform_family'] == 'debian'
	%w{ 
	  xinetd
	  check-mk-livestatus
	}.each do |pkg|
	  package pkg
	end

  service "xinetd" do
    action [ :nothing ]
    supports :status => true, :start => true, :stop => true, :restart => true
  end

  # Determine hosts to allow connections from
  splunk_host = ['127.0.0.1']

  # Find all splunk servers in Chef
  search(:node, 'recipes:splunk\:\:server') do |n|
    splunk_host << n['ipaddress']
  end

	# Set up a xinetd livestatus service
	template "/etc/xinetd.d/livestatus" do
    source "livestatus.erb"
    variables(
      :splunk_host => splunk_host
    )
    notifies :restart, resources(:service => "xinetd")
  end
end