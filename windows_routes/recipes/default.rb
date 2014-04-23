#
# Cookbook Name:: windows_routes
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
skiproutes = false
if node['windows'].nil?
  skiproutes = true
elsif node['windows']['routing'].nil?
  skiproutes = true
elsif node['windows']['routing']['routes'].nil?
  skiproutes = true
end

unless skiproutes
  old_state = node['windows']['routing']['state'] if node['windows']['routing']['state']
  old_state ||= []
  new_state = node['windows']['routing']['routes'] if node['windows']['routing']['routes']
  new_state ||= []
  Chef::Log.debug "Old routing table state:#{old_state}"
  Chef::Log.debug "New routing table state:#{new_state}"
  
  #check to see if the routing rules changed.
  #the rules are always changed the first run
  if old_state == new_state
    Chef::Log.info "Routing table unchanged."
  else
    Chef::Log.info "Routing table updated."
    node['windows']['routing']['routes'].each do |route|
      unless old_state.include?(route)
        metric = " metric #{route.first[1]['metric']}" if route.first[1]['metric']
        metric ||= ""
        persistent = ' -p'
        if route.first[1]['temporary']
          persistent = ''
        end
        execute "route add #{route.first[0]} mask #{route.first[1]['mask']} #{route.first[1]['gateway']}#{metric}#{persistent}"
      end
    end
    node.set['windows']['routing']['state'] = new_state
  end
end
