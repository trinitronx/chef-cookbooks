include_recipe 'rvm::system'

rvm_ruby = node['rvm']['default_ruby']
passenger_version = node['passenger_biola']['passenger']['version']
passenger_prefix = node['passenger_biola']['passenger']['prefix']
nginx_user = node['passenger_biola']['nginx']['user']

passenger_root = "/usr/local/rvm/gems/#{rvm_ruby}/gems/passenger-#{passenger_version}"
passenger_ruby = "/usr/local/rvm/wrappers/#{rvm_ruby}/ruby"

rvm_environment rvm_ruby

template '/etc/init.d/nginx' do
  source    'nginx.init.d.erb'
  owner     'root'
  group     'root'
  mode      '0755'
  variables :prefix => passenger_prefix
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action :start
end

rvm_gem 'passenger' do
  ruby_string rvm_ruby
  version passenger_version
end

directory '/var/log/nginx' do
  user nginx_user
  group 'root'
  mode '0755'
  action :create
end

rvm_shell 'install passenger_nginx_module' do
  ruby_string rvm_ruby

  code "passenger-install-nginx-module --auto --prefix=#{passenger_prefix} --auto-download"

  notifies :restart, resources(:service => 'nginx')

  not_if "#{passenger_prefix}/sbin/nginx -V 2>&1 | grep passenger-#{passenger_version}"
end

link '/etc/nginx' do
  to "#{passenger_prefix}/conf"
end

link '/usr/sbin/nginx' do
  to "#{passenger_prefix}/sbin/nginx"
end

template "#{passenger_prefix}/conf/nginx.conf" do
  source    'nginx.conf.erb'
  owner     'root'
  group     'root'
  mode      '0644'
  variables node['passenger_biola']['nginx'].to_hash.merge 'passenger_root' => passenger_root, 'passenger_ruby' => passenger_ruby

  notifies  :restart, resources(:service => 'nginx')
end

directory "#{passenger_prefix}/conf/sites" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/srv/www' do
  owner 'root'
  group 'root'
  mode '0775'
  action :create
end