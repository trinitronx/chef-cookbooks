#
# Cookbook Name:: windows_registry
# Recipe:: default
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

# Parse through the ['windows']['registry'] attribute for registry keys
if node.attribute?('windows') && node['windows'].attribute?('registry')
  node['windows']['registry'].each do |r|
    # Don't allow recursively deleting keys
    unless r['recursive'] && r['action'] == 'delete_key'
      if r['key_name']
        # This resource wants symbols, not strings
        registry_values = Array.new
        r['values'].each do |v|
          h = Hash.new
          v.each do |key, value|
            h[key.to_sym] = (key == 'type') ? value.to_sym : value
          end
          registry_values << h
        end

        registry_key r['key_name'] do
          values registry_values
          if r['recursive']
            recursive true
          end
          if r['action']
            action r['action']
          end
        end
      end
    end
  end
end