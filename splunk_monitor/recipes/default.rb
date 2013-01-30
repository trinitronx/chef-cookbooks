#
# Cookbook Name:: splunk_monitor
# Recipe:: default
#
# Copyright 2012, Biola University 
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

include_recipe "splunk::forwarder"

# Splunk forwarder package installation will generate a new user
user "splunk" do
  action :remove
  ignore_failure true
end

if node[:splunk][:hostname_source] == "node_name"
	splunk_hostname = node.name
else
	splunk_hostname = node[:hostname]
end

# Update splunk default hostname in system inputs.conf
template "/opt/splunkforwarder/etc/system/local/inputs.conf" do
	source "system-inputs.conf.erb"
	owner "root"
	group "root"
	mode "0600"
	variables({
		:splunk_hostname => splunk_hostname
	})
	notifies :restart, resources(:service => "splunk")
end

# Update splunk servername just before splunk is to be restarted
splunk_cmd = "#{node['splunk']['forwarder_home']}/bin/splunk"
execute "update_splunk_servername" do
	command splunk_cmd + " set servername "+ splunk_hostname + " -auth " + node['splunk']['auth'] 
	subscribes :run, resources(:template => "/opt/splunkforwarder/etc/system/local/inputs.conf"), :immediately
        action :nothing
end


if node[:splunk][:monitors] 
	directory "/opt/splunkforwarder/etc/apps/search/local" do
	  owner "root"
	  group "root"
	  action :create
	end
	template "/opt/splunkforwarder/etc/apps/search/local/inputs.conf" do
		source "inputs.conf.erb"
		owner "root"
		group "root"
		mode "0600"
		variables ({
			:splunk_monitors => node[:splunk][:monitors]
		})
		notifies :restart, resources(:service => "splunk")
	end
	# Now check and apply transforms as well
	if node[:splunk][:transforms]
		directory "/opt/splunkforwarder/etc/system/local" do
		  owner "root"
		  group "root"
		  action :create
		end
		template "/opt/splunkforwarder/etc/system/local/transforms.conf" do
			source "system-transforms.conf.erb"
			owner "root"
			group "root"
			mode "0600"
			variables ({
				:splunk_transforms => node[:splunk][:transforms]
			})
			notifies :restart, resources(:service => "splunk")
		end
		template "/opt/splunkforwarder/etc/system/local/props.conf" do
			source "system-props.conf.erb"
			owner "root"
			group "root"
			mode "0600"
			variables ({
				:splunk_props => node[:splunk][:props]
			})
			notifies :restart, resources(:service => "splunk")
		end
	end
end
