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

#servicename will depend on the OS
case node[:os]
when "windows"
  servicename = "SplunkForwarder"
when "linux"
  servicename = "splunk"
end

if node["os"] == "linux"

  include_recipe "splunk::forwarder"

  # Splunk forwarder package installation will generate a new user
  user "splunk" do
    action :remove
    ignore_failure true
  end

  # This user removal can leave directories stranded -- will reset
  # back to root user
  execute "chown --recursive root:root #{node['splunk']['forwarder_home']}"

end


if node["os"] == "windows"
  include_recipe "splunk_windows::default"
end

case node[:os]
when "windows"
  service "SplunkForwarder" do
    action [ :nothing ]
    supports :status => true, :start => true, :stop => true, :restart => true
  end
end

# To avoid confusion between systems with the same hostname, add the subdomain if configured
if node[:splunk][:hostname_source] == "hostname_with_subdomain"
	splunk_hostname = node['fqdn'].gsub(/\.\w*\.\w*$/, '')
elsif node[:splunk][:hostname_source] == "node_name"
	splunk_hostname = node.name
else
	splunk_hostname = node[:hostname]
end

# Save the hostname in the node's attributes
node.set['splunk']['hostname'] = splunk_hostname

# Update splunk default hostname in system inputs.conf
template "#{node['splunk']['forwarder_home']}/etc/system/local/inputs.conf" do
	source "system-inputs.conf.erb"
	if node["os"] == "linux"
		owner "root"
		group "root"
		mode "0600"
	end
	variables({
		:splunk_hostname => splunk_hostname
	})
	notifies :restart, resources(:service => servicename)
end

# Update splunk servername just before splunk is to be restarted
splunk_cmd = "#{node['splunk']['forwarder_home']}/bin/splunk"
if node["os"] == "linux"
  execute "update_splunk_servername" do
    command "\"" + splunk_cmd + "\"" + " set servername "+ splunk_hostname + " -auth " + node['splunk']['auth'] 
    subscribes :run, resources(:template => "#{node['splunk']['forwarder_home']}/etc/system/local/inputs.conf"), :immediately
    action :nothing
  end
end

# Servername update for windows
if node["os"] == "windows"
  windows_batch "update_splunk_servername" do
    code <<-EOH
    "#{splunk_cmd}" set servername #{splunk_hostname} -auth #{node['splunk']['auth']}
    EOH
    subscribes :run, resources(:template => "#{node['splunk']['forwarder_home']}/etc/system/local/inputs.conf"), :immediately
    action :nothing
  end
end

if node[:splunk][:monitors] 
	directory "#{node['splunk']['forwarder_home']}/etc/apps/search/local" do
	  if node["os"] == "linux"
		owner "root"
		group "root"
	  end
	  action :create
	end
	template "#{node['splunk']['forwarder_home']}/etc/apps/search/local/inputs.conf" do
		source "inputs.conf.erb"
		if node["os"] == "linux"
			owner "root"
			group "root"
			mode "0600"
		end
		variables ({
			:splunk_monitors => node[:splunk][:monitors]
		})
		notifies :restart, resources(:service => servicename)
	end
	# Now check and apply transforms as well
	if node[:splunk][:transforms]
		directory "#{node['splunk']['forwarder_home']}/etc/system/local" do
		if node["os"] == "linux"
			owner "root"
			group "root"
		end
		  action :create
		end
		template "#{node['splunk']['forwarder_home']}/etc/system/local/transforms.conf" do
			source "system-transforms.conf.erb"
			if node["os"] == "linux"
				owner "root"
				group "root"
				mode "0600"
			end
			variables ({
				:splunk_transforms => node[:splunk][:transforms]
			})
			notifies :restart, resources(:service => servicename)
		end
		template "#{node['splunk']['forwarder_home']}/etc/system/local/props.conf" do
			source "system-props.conf.erb"
			if node["os"] == "linux"
				owner "root"
				group "root"
				mode "0600"
			end
			variables ({
				:splunk_props => node[:splunk][:props]
			})
			notifies :restart, resources(:service => servicename)
		end
	end
end
