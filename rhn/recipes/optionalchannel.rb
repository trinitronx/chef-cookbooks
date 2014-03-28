#
# Cookbook Name:: rhn
# Recipe:: optionalchannel
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

if File.exists?('/etc/sysconfig/rhn/systemid')
  channelcheck = Mixlib::ShellOut.new("rhn-channel -l")
  channelcheck.run_command
  unless channelcheck.stdout =~ /optional/
    execute "sudo rhn-channel --add --channel rhel-#{node['kernel']['machine']}-#{node['rhn']['operating_system']}-optional-#{node['platform_version'].split('.')[0]} -u \"#{node['rhn']['username']}\" -p \"#{node['rhn']['password']}\""
  end
end
