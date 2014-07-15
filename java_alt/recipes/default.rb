#
# Cookbook Name:: java_alt
# Recipe:: default
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

# Setup the Oracle cookie acceptance attribute
accept_oracle_download_terms = false
if node['java']
  if node['java']['oracle']
    if node['java']['oracle']['accept_oracle_download_terms']
      accept_oracle_download_terms = node['java']['oracle']['accept_oracle_download_terms']
    end
  end
end

template "#{Chef::Config[:file_cache_path]}/java_alt.rb" do
  source "java_alt.rb.erb"
end

template "#{Chef::Config[:file_cache_path]}/java_alt.json" do
  source "java_alt.json.erb"
  variables({
     :accept_oracle_download_terms => accept_oracle_download_terms
  })
end

template "#{Chef::Config[:file_cache_path]}/javainstall.txt" do
  source "javainstall.txt.erb"
end

# Running in the background to avoid chef-solo waiting on chef-client

# Should be safe to run after each chef-client run
#unless File.exist?('/usr/lib/jvm/java_alt')
package 'at'
service 'atd' do
  action :start
end
execute "at -f #{Chef::Config[:file_cache_path]}/javainstall.txt now + 3 minutes"
#end
