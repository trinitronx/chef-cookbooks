#
# Cookbook Name:: opsview
# Recipe:: pagerduty
#
# Copyright 2014, Biola University
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

# Install dependencies
package "libwww-perl"
package "libcrypt-ssleay-perl"

# Install the notification script
template "/usr/local/nagios/libexec/notifications/pagerduty_nagios.pl" do
  source "pagerduty_nagios.pl.erb"
  owner "nagios"
  group "nagios"
  mode 0755
  action :create
end

# Set up the cron entry
cron 'Flush Pagerduty' do
  user "nagios"
  mailto 'root@localhost'
  command "/usr/local/nagios/libexec/notifications/pagerduty_nagios.pl flush"
end

# Create the PagerDuty contact and notification method
admin_password = node['opsview']['admin_password']
%w{ notificationmethod sharednotificationprofile contact }.each do | object_type | 
  template "#{node['opsview']['json_config_dir']}/pagerduty-#{object_type}.json" do
    source "pagerduty-#{object_type}.json.erb"
    mode 0644
    notifies :run, "execute[put pagerduty-#{object_type}]", :immediately
    notifies :run, "execute[reload opsview config]", :delayed
  end

  execute "put pagerduty-#{object_type}" do
    command "#{node['opsview']['opsview_rest_path']}  --username=admin --password=#{admin_password} --content-file=#{node['opsview']['json_config_dir']}/pagerduty-#{object_type}.json --data-format=json --pretty PUT config/#{object_type}"
    action :nothing
  end
end

# Reload the Opsview config
execute "reload opsview config" do
  command "#{node['opsview']['opsview_rest_path']}  --username=admin --password=#{admin_password} POST reload"
  action :nothing
end