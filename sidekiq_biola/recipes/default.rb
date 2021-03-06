directory '/var/log/sidekiq' do
  user 'root'
  group 'root'
  mode '0777'
  action :create
end

deployed_apps = node[:sidekiq_biola][:apps].select do |app|
  File.exists? File.join(node[:sidekiq_biola][:app_root], app[:name])
end

deployed_apps.each do |app|
  template  "/etc/init/sidekiq-#{app[:name]}.conf" do
    source 'etc-init-sidekiq.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables app_root: node[:sidekiq_biola][:app_root], app: app

    notifies :stop, 'service[sidekiq-all]', :delayed
    notifies :start, 'service[sidekiq-all]', :delayed
  end
end

template '/etc/init/sidekiq-all.conf' do
  source 'etc-init-sidekiq-all.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables apps: deployed_apps
end

service 'sidekiq-all' do
  provider Chef::Provider::Service::Upstart
  supports status: true, restart: true
  action :start
end