#
# Cookbook Name:: logrotate_apps
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

node['logrotate']['apps'].each_with_index do |parameters, index|
  parameters.each_key do |app_name|
    logrotate_app parameters.keys[0].to_s do
      path parameters[app_name]['path'] if parameters[app_name]['path']
      enable parameters[app_name]['enable'] if parameters[app_name]['enable']
      frequency parameters[app_name]['frequency'] if parameters[app_name]['frequency']
      rotate parameters[app_name]['rotate'] if parameters[app_name]['rotate']
      size parameters[app_name]['size'] if parameters[app_name]['size']
      template parameters[app_name]['template'] if parameters[app_name]['template']
      cookbook parameters[app_name]['cookbook'] if parameters[app_name]['cookbook']
      create parameters[app_name]['create'] if parameters[app_name]['create']
      postrotate parameters[app_name]['postrotate'] if parameters[app_name]['postrotate']
      prerotate parameters[app_name]['prerotate'] if parameters[app_name]['prerotate']
      sharedscripts parameters[app_name]['sharedscripts'] if parameters[app_name]['sharedscripts']
    end
  end
end