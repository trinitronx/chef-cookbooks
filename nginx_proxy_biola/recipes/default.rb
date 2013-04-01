config_dir = '/etc/nginx'

include_recipe 'users::devops'

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