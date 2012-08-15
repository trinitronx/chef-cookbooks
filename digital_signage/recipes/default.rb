#
# Cookbook Name:: digital_signage
# Recipe:: default
#
# Copyright 2012, Biola University
#
# All rights reserved - Do Not Redistribute
#

include_recipe "digital_signage::settings"
include_recipe "digital_signage::adobe_air"

# Install the Digital Signage Client from node['digital_signage']['client']['url']
remote_file "#{Chef::Config['file_cache_path']}/DigitalSignage.air" do
  source node['digital_signage']['client']['url'] # Note this downloads every time in order to run a checksum
  checksum "6bfbd3abfbd8a40b4b18cb0bd8bcc3ff677b4fb4fd138313d54d543b20c0ca03" #TODO: Move to attribute
  notifies :run, "execute[install-digitalsignage-player-air-app]", :immediately
end

# This block does NOT support upgrades to the digital signage player. -- TODO: Create an upgrade recipe
execute "install-digitalsignage-player-air-app" do
  command "arh -installAppSilent #{Chef::Config['file_cache_path']}/DigitalSignage.air"
  returns [0,1,6,8,9] # see http://goo.gl/AxMON for installer exit codes
  action :nothing
end

# Install the Digital Signage LaunchD plists
template "/Library/LaunchDaemons/edu.biola.digsig.plist" do
  source "edu.biola.digsig.plist.erb"
  owner "root"
  group "wheel"
  mode 0755
  notifies :run, "execute[load-edu-biola-digsig-plist]", :immediately
end

template "/Library/LaunchDaemons/edu.biola.killDigitalSignage.plist" do
  source "edu.biola.killDigitalSignage.plist.erb"
  owner "root"
  group "wheel"
  mode 0755
  notifies :run, "execute[load-edu-biola-killDigitalSignage-plist]", :immediately
end

execute "load-edu-biola-digsig-plist" do
  command "launchctl load /Library/LaunchDaemons/edu.biola.digsig.plist"
  action :nothing
end

execute "load-edu-biola-killDigitalSignage-plist" do
  command "launchctl load /Library/LaunchDaemons/edu.biola.killDigitalSignage.plist"
  action :nothing
end

# Install the Digital Signage start/stop scripts
cookbook_file "/Applications/start_digital_signage.command" do
  owner "root"
  group "wheel"
  mode 0755
end

cookbook_file "/Applications/stop_digital_signage.command" do
  owner "root"
  group "wheel"
  mode 0755
end

# TODO: Add /Applications/start_digital_signage.command to Dig Sig's start up items

# This disables Adobe Air from auto updating
cookbook_file "/Users/digsig/Library/Application Support/Adobe/Air/updateDisabled" do
  source "updateDisabled"
  owner "digsig"
  group "staff"
end