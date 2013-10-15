require 'yaml'

class Chef::Recipe
  include RubyApp::DomainHelpers
end

class Erubis::Context
  include RubyApp::DomainHelpers
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
  apps = RubyApp::AppsCollection.new

  # Apps deployed to this host
  Dir.chdir apps_dir
  Dir['*'].each do |app_name|
    if data_bag(data_bag_name).include? app_name
      apps << RubyApp::App.new(data_bag_item(data_bag_name, app_name))
    end
  end

  # Setup user, group, directories, etc. for each app
  apps.each do |app|
    app_dir = "#{apps_dir}/#{app.name}"

    group app.username do
      action :create
    end

    user app.username do
      gid app.username
      system true
      action :create
    end

    directory "#{logs_dir}/#{app.name}" do
      user app.username
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
      user app.username
      group dev_group
      to "#{logs_dir}/#{app.name}"
      action :create
    end

    directory "#{app_dir}/tmp" do
      user app.username
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
      code "chown --recursive #{app.username} ./tmp/ ./log/"
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
    if data_bag(conf_data_bag_name).include? app.name
      conf_data_bag_item = Chef::EncryptedDataBagItem.load(conf_data_bag_name, app.name, data_bag_secret)
      conf_files = Array(conf_data_bag_item['files'])

      if conf_data_bag_item[node.chef_environment]
        conf_files += Array(conf_data_bag_item[node.chef_environment]['files'])
      end

      conf_files.each do |filename, hash|
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
  apps.domains.each do |domain|
    rack_env    = (node.chef_environment == 'prod' ? 'production' : 'staging')
    env_domain  = domain.for_environment(rack_env)

    template "#{nginx_sites_dir}/#{env_domain}.server.conf" do
      source    'nginx_site.server.conf.erb'
      owner     'root'
      group     'root'
      mode      '0644'
      variables apps_dir: apps_dir, static_dir: static_dir, rack_env: rack_env, domain: domain
    end

    if domain.non_root_apps?
      directory "#{static_dir}/#{env_domain}" do
        user 'root'
        group dev_group
        mode '0775'
        action :create
      end

      domain.non_root_apps.each do |app|
        link "#{static_dir}/#{env_domain}/#{app.url_path}" do
          user 'root'
          group dev_group
          to "#{apps_dir}/#{app.name}/public"
          action :create
        end
      end
    end
  end
end