#
# Cookbook Name:: windows_tasks
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

if node['platform'] == "windows" then
  # Deploy all of the scripts in the cookbook
  remote_directory node['windows']['scripts']['scripts_dir'] do
    source "scripts"
    owner node['windows']['scripts']['owner']
    files_owner node['windows']['scripts']['owner']
  end

  # Update file permissions
  directory node['windows']['scripts']['scripts_dir'] do
  	rights :full_control, node['windows']['scripts']['owner'], :applies_to_children => true
  end
end