dev_group = node['ruby_app']['dev_group']

directory '/srv/rails' do
  user 'root'
  group dev_group
  mode '0775'
  action :create
end

template '/etc/profile.d/rails.sh' do
  source    'rails.sh.erb'
  owner     'root'
  group     'root'
  mode      '0644'
  variables node['ruby_app'].to_hash
end

directory '/var/log/rails' do
  user 'root'
  group dev_group
  mode '0775'
  action :create
end

include_recipe 'logrotate::default'
logrotate_app 'rails' do
  cookbook 'logrotate'
  path '/var/log/rails/*/*.log'
  frequency 'daily'
  rotate 7
  create "644 root #{dev_group}"
end