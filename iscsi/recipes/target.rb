#
# Cookbook Name:: iscsi
# Recipe:: target
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

package "iscsitarget-dkms"
package "iscsitarget"

# Do nothing until attributes are defined
if node['iscsi']
  if node['iscsi']['targets']
    # Enable iscsi target service in debian default file
    template "/etc/default/iscsitarget"
    
    template "/etc/iet/ietd.conf" do
      variables ({
        :iscsi_targets => node[:iscsi][:targets]
      })
    end
    
    template "/etc/iet/initiators.allow" do
      variables ({
        :iscsi_targets => node[:iscsi][:targets]
      })
    end
    
    service "iscsitarget" do
      supports :status => true, :restart => true, :start => true, :stop => true
      action [ :enable, :start ]
    end
  end
end
