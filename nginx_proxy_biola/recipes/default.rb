#
# Cookbook Name:: nginx_proxy_biola
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


config_dir = '/etc/nginx'

package 'nginx'
package 'fabric' # Python deployment framework
package 'git-core'

directory config_dir do
  group 'devops'
  mode 0775
end

settings = node[:nginx_proxy_biola] || {}

if settings[:git_repo_url]
  unless Dir.exists? File.join(config_dir, '.git')
    require 'fileutils'

    FileUtils.rm_rf(File.join(config_dir, '.'), :secure => true)
  end
end

template File.join(config_dir, 'fabfile.py') do
  source 'fabfile.py.erb'
  owner 'root'
  group 'devops'
  mode 0775

  prod_proxies = search(:node, 'role:nginx_proxy_host AND chef_environment:prod')

  variables :hosts => prod_proxies.map(&:fqdn)
end

service 'nginx' do
  action :start
end
