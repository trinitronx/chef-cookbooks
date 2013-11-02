#
# Cookbook Name:: linux_scripts
# Recipe:: remote_scripts
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

if node['remote_scripts']
  node['remote_scripts'].each do |script|
    script.each_key do |scriptname|
      remote_file "#{scriptname}" do
        source script[scriptname]['source']
        path script[scriptname]['path']
        if script[scriptname]['mode']
          mode script[scriptname]['mode']
        else
          mode 0555
        end
      end
    end
  end
end
