#
# Cookbook Name:: windows_firewall
# Recipe:: default
#
# Copyright 2014, Biola University 
# Copyright 2011, Opscode, Inc
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

# Check for conditions which require this recipe to be skipped
skipfirewall = false
if node['firewall'].nil?
  skipfirewall = true
end
# Disabled firewall on Server 2003 check
if node['kernel']['name'] =~ /Server 2003/
  if `sc query "SharedAccess"` =~ /STATE\s*:\ 1\s*STOPPED/
    skipfirewall = true
  end
end

unless skipfirewall
  old_state = node['firewall']['state'] if node['firewall']['state']
  old_state ||= ""
  new_state = node['firewall']['rules'].to_s if node['firewall']['rules']
  new_state ||= ""
  Chef::Log.debug "Old firewall state:#{old_state}"
  Chef::Log.debug "New firewall state:#{new_state}"
  
  #check to see if the firewall rules changed.
  #the rules are always changed the first run
  if old_state == new_state
    Chef::Log.info "Firewall rules unchanged."
  else
    class Chef::Recipe
      include CheckOpenPort
    end
    Chef::Log.info "Firewall rules updated."
    node.set['firewall']['state'] = new_state
    if node['firewall']['rules']
      node['firewall']['rules'].each do |rule_mash|
        rule_mash.keys.each do |rule|
          params = rule_mash[rule]
          name = params['name'] if params['name']
          name ||= rule
          protocol = params['protocol'].upcase if params['protocol']
          protocol ||= "TCP"
          direction = params['direction'].to_sym if params['direction']
          interface = params['interface'] if params['interface']
          logging = params['logging'].to_sym if params['logging']
          port = params['port'].to_i if params['port']
          source = params['source'] if params['source']
          source ||= "any"
          destination = params['destination'] if params['destination']
          dest_port = params['dest_port'].to_i if params['dest_port']
          profile = params['profile'] if params['profile']
          profile ||= "domain"
          execute "netsh advfirewall firewall add rule name=\"#{name}\" dir=in action=allow protocol=#{protocol} localport=#{port} remoteip=#{source} profile=#{profile}" do
            not_if {CheckOpenPort.is_port_open?(node['ipaddress'], port)}
          end
        end
      end
    end
  end
end
