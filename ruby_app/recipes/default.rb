require 'fileutils'
require 'yaml'

data_bag_name       = node['ruby_app']['data_bag_name']
conf_data_bag_name  = node['ruby_app']['conf_data_bag_name']
encryption_key_path = node['ruby_app']['encryption_key_path']
dev_group           = node['ruby_app']['dev_group']
apps_dir            = node['ruby_app']['apps_dir']
static_dir          = node['ruby_app']['static_dir']
logs_dir            = node['ruby_app']['logs_dir']
nginx_sites_dir     = node['ruby_app']['nginx_sites_dir']
default_user        = node['ruby_app']['default_user']

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
    username = app.username || default_user

    if app.group_name
      group app.group_name do
        gid = app.gid
        action :create
      end
    end

    if app.username
      user app.username do
        uid app.uid
        gid app.group_name
        system true
        action :create
      end
    end

    directory "#{logs_dir}/#{app.name}" do
      user username
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
      user username
      group dev_group
      to "#{logs_dir}/#{app.name}"
      action :create
    end

    if app.url?
      directory "#{app_dir}/public" do
        user username
        group dev_group
        mode '0775'
        action :create
        not_if { Dir.exists? "#{app_dir}/public"}
      end
    end

    directory "#{app_dir}/tmp" do
      user username
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
      code "chown --recursive #{username} ./tmp/ ./log/"
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
      app_conf = RubyApp::Config.new(conf_data_bag_item.to_hash, node.chef_environment)

      app_conf.files.each do |file_name, file_content|
        path = File.expand_path("#{app_dir}/#{file_name}")

        # Be sure we're not messing with files we shouldn't be
        if path =~ /^#{app_dir}/
          # Ensure the directory the file lives in exists
          directory File.dirname(path) do
            user 'root'
            group dev_group
            mode '0775'
            recursive true
            action :create
            not_if { Dir.exists? File.dirname(path) }
          end

          file path do
            user username
            group dev_group
            mode '0660' # not world readable becase there is sensitive info in these files
            content file_content
            action :create
          end
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

      # Create any extra paths between the domain and the app. Like example.com/something/something/app.
      domain.non_root_apps.select(&:url_parent_path?).each do |app|
        directory "#{static_dir}/#{env_domain}/#{app.url_parent_path}" do
          user 'root'
          group dev_group
          mode '0775'
          action :create
        end
      end
    end

    # Move the public files from /public to the static dir and symlink public to it.
    domain.apps.each do |app|
      public_path = "#{apps_dir}/#{app.name}/public"
      static_path = "#{static_dir}/#{env_domain}"
      static_path += "/#{app.url_path}" if app.url_path?

      ruby_block "move #{public_path} to #{static_path}" do
        block do
          if File.exists?(public_path) && !File.symlink?(public_path)
            FileUtils.move public_path, static_path
          end
        end
      end

      link public_path do
        user app.username || default_user
        group dev_group
        to static_path
        action :create
      end
    end
  end
end