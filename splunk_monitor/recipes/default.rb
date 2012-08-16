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

if node[:splunk][:monitors] 


	directory "/opt/splunkforwarder/etc/apps/search/local" do
	  owner "splunk"
	  group "splunk"
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
end
