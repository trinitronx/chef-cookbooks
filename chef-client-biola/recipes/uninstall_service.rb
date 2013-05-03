#
# Cookbook Name:: chef-client-biola
# Recipe:: uninstall_service
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

# Stop and disable the chef-client service
service "chef-client" do
	action [ :disable, :stop ]
end

case node["chef_client"]["init_style"]
when "upstart"

when "init"

when "winsw"

when "launchd"

else
  log "Could not determine service init style, manual intervention required to remove the chef-client service."
end