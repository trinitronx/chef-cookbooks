require 'yaml'

class Chef::Recipe
  include RubyAppDomainHelpers
end

class Erubis::Context
  include RubyAppDomainHelpers
end

data_bag_name       = node['ruby_app']['data_bag_name']
conf_data_bag_name  = node['ruby_app']['conf_data_bag_name']
encryption_key_path = node['ruby_app']['encryption_key_path']
dev_group           = node['ruby_app']['dev_group']
apps_dir            = node['ruby_app']['apps_dir']
static_dir          = node['ruby_app']['static_dir']
logs_dir            = node['ruby_app']['logs_dir']
nginx_sites_dir     = node['ruby_app']['nginx_sites_dir']

data_bag_secret = Chef::EncryptedDataBagItem.load_secret(encryption_key_path)

directory apps_dir do
  user 'root'
  group dev_group
  mode '0775'
  action :create
end

directory static_dir do
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

directory logs_dir do
  user 'root'
  group dev_group
  mode '0775'
  action :create
end

include_recipe 'logrotate::default'
logrotate_app 'rails' do
  cookbook 'logrotate'
  path "#{logs_dir}/*/*.log"
  frequency 'daily'
  rotate 7
  create "644 root #{dev_group}"
end

if File.exists? apps_dir
  # Apps deployed to this host
  apps = {}
  Dir.chdir apps_dir
  Dir['*'].each do |app_name|
    if data_bag(data_bag_name).include? app_name
      apps[app_name] = data_bag_item(data_bag_name, app_name)
    end
  end

  # Apps on this host by domain
  domains = apps.values.group_by do |app|
    concat_domain(app['url']['subdomain'], app['url']['domain'])
  end

  # Setup user, group, directories, etc. for each app
  apps.each do |app_name, data|
    app_dir = "#{apps_dir}/#{app_name}"
    app_username = username_for(app_name)

    group app_username do
      action :create
    end

    user app_username do
      gid app_username
      system true
      action :create
    end

    directory "#{logs_dir}/#{app_name}" do
      user app_username
      group dev_group
      mode '0775'
      action :create
    end

    directory "#{app_dir}/log" do
      action :delete
      recursive true
      not_if { File.symlink? "#{app_dir}/log" }
    end

    link "#{app_dir}/log" do
      user app_username
      group dev_group
      to "#{logs_dir}/#{app_name}"
      action :create
    end

    directory "#{app_dir}/tmp" do
      user app_username
      group dev_group
      mode '0775'
      action :create
    end

    bash 'set group on all files' do
      cwd app_dir
      code "chgrp --recursive #{dev_group} . ./log/"
    end

    bash 'set onwer on some files' do
      cwd app_dir
      code "chown --recursive #{app_username} ./tmp/ ./log/"
    end

    bash 'make files group writable' do
      cwd app_dir
      code 'chmod --recursive g+w . ./log/'
    end

    bash 'set git repo sharedRepository = true' do
      cwd app_dir
      code 'git config core.sharedRepository group'
      only_if { Dir.exists? "#{app_dir}/.git" }
    end

    # Write config files for each app
    if data_bag(conf_data_bag_name).include? app_name
      conf_data_bag_item = Chef::EncryptedDataBagItem.load(conf_data_bag_name, app_name, data_bag_secret)

      Array(conf_data_bag_item['files']).each do |filename, hash|
        file "#{app_dir}/config/#{filename}" do
          user 'root'
          group dev_group
          mode '0664'
          content YAML::dump(hash)
          action :create
        end
      end
    end
  end

  # Setup Nginx for each domain
  domains.each do |domain, apps|
    subdomain   = apps.first['url']['subdomain']
    domain      = apps.first['url']['domain']
    rack_env    = (node.chef_environment == 'prod' ? 'production' : 'staging')
    env_domain  = concat_domain(subdomain, ('staging' if rack_env == 'staging'), domain)
    host_domain = concat_domain(subdomain, node['fqdn'])

    template "#{nginx_sites_dir}/#{env_domain}.server.conf" do
      source    'nginx_site.server.conf.erb'
      owner     'root'
      group     'root'
      mode      '0644'
      variables env_domain: env_domain, host_domain: host_domain, apps_dir: apps_dir, static_dir: static_dir, rack_env: rack_env, apps: apps
    end

    if apps.any? { |app| app['url']['path'].to_s =~ /\w/ }
      directory "#{static_dir}/#{env_domain}" do
        user 'root'
        group dev_group
        mode '0775'
        action :create
      end

      apps.each do |app|
        link "#{static_dir}/#{env_domain}/#{app['url']['path']}" do
          user 'root'
          group dev_group
          to "#{apps_dir}/#{app['id']}/public"
          action :create
        end
      end
    end
  end
end