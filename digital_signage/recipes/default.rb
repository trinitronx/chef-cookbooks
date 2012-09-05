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
  mode '4755'
end

cookbook_file "/Applications/stop_digital_signage.command" do
  owner "root"
  group "wheel"
  mode '4755'
end

cookbook_file "/etc/sudoers" do
  owner "root"
  group "wheel"
  mode '440'
  action :nothing
end

# Add /Applications/start_digital_signage.command to Dig Sig's start up items
# See http://hints.macworld.com/article.php?story=20111226075701552
execute "add-digital-signage-startup-item" do
  command "osascript -e 'tell application \"System Events\" to make login item at end with properties {path:\"/Applications/start_digital_signage.command\", hidden:true}'"
  not_if { `osascript -e 'tell application "System Events" to get the name of every login item'`.strip == "start_digital_signage.command" }  
end

# This disables Adobe Air from auto updating
cookbook_file "/Users/digsig/Library/Application Support/Adobe/Air/updateDisabled" do
  source "updateDisabled"
  owner "digsig"
  group "staff"
end

execute "add-signage-player-to-dock" do
  user "digsig"
  command "defaults write /Users/digsig/Library/Preferences/com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Digital Signage.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'"
  only_if {`defaults read /Users/digsig/Library/Preferences/com.apple.dock persistent-apps | grep "Applications/Digital Signage.app"`.empty?}
  notifies :run, "execute[killall-dock]", :immediately
end

execute "add-signage-start-command-to-dock" do
  user "digsig"
  command "defaults write /Users/digsig/Library/Preferences/com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/start_digital_signage.command</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'"
  only_if {`defaults read /Users/digsig/Library/Preferences/com.apple.dock persistent-apps | grep "Applications/start_digital_signage.command"`.empty?}
  notifies :run, "execute[killall-dock]", :immediately
end

execute "add-signage-stop-command-to-dock" do
  user "digsig"
  command "defaults write /Users/digsig/Library/Preferences/com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/stop_digital_signage.command</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'"
  only_if {`defaults read /Users/digsig/Library/Preferences/com.apple.dock persistent-apps | grep "Applications/stop_digital_signage.command"`.empty?}
  notifies :run, "execute[killall-dock]", :immediately
end

execute "killall-dock" do
 command "killall Dock"
 action :nothing
end

# TODO: Test out `defaults write com.apple.dock single-app -bool true; killall Dock` -- see if this shows digital signage better

# Hide the dock
execute "hide-the-dock" do
  command "osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to true'"
  not_if { `defaults read /Users/digsig/Library/Preferences/com.apple.Dock autohide`.strip == "1" }
end

# TODO: Create digsig user and set password. Do this last
# dscl -u digsig -P CURRENT_PASSWORD /Local/Default -passwd /Users/ USERNAME PASSWORD
