#
# Cookbook Name:: digital_signage
# Recipe:: adobe_air
#
# Copyright 2012, Biola University
#
# All rights reserved - Do Not Redistribute
#

# ------------------#
# -----IMPORTANT: Adobe Air doesn't support upgrading through command line so this does nothing if you already have Adobe Air installed! ---
# ------------------#

# Get Adobe Air version using `arh -runtimeVersion`
arh = "#{node['digital_signage']['adobe_air']['arh_install_path']}/arh"
remote_file "#{arh}" do
  source "http://airdownload.adobe.com/air/distribution/latest/mac/arh"
  owner "root"
  group "staff"
  mode "755"
  action :nothing
end

# See if arh has changed
http_request "HEAD http://airdownload.adobe.com/air/distribution/latest/mac/arh" do
  message ""
  url "http://airdownload.adobe.com/air/distribution/latest/mac/arh"
  action :head
  if File.exists?(arh)
    headers "If-Modified-Since" => File.mtime(arh).httpdate
  end
  notifies :create, "remote_file[#{arh}]", :immediately
end

if (node['digital_signage']['adobe_air']['installed_version'].nil? || node['digital_signage']['adobe_air']['installed_version'].length == 0)
  # Download Adobe Air
  remote_file "#{Chef::Config['file_cache_path']}/AdobeAir.dmg" do
    source node['digital_signage']['adobe_air']['url'] # Note this downloads every time in order to run a checksum
    checksum "4eb7dfe60f4b0c1597ecef202ad3d2b4320033a5fe56345ee7e38acee7bfb4cb" #TODO: Move to attribute
  end
  
  # Mount Adobe Air dmg
  execute "mount-adobe-air-installer" do
    command "hdiutil attach #{Chef::Config['file_cache_path']}/AdobeAir.dmg -nobrowse"
    not_if File.exist? '/Volumes/Adobe\ Air'
  end
  
  # Install Adobe Air
  execute "install-adobe-air" do
    command '/Volumes/Adobe\ AIR/Adobe\ AIR\ Installer.app/Contents/MacOS/Adobe\ AIR\ Installer -silent -eulaAccepted'
    only_if File.exist? '/Volumes/Adobe\ AIR/Adobe\ AIR\ Installer.app/Contents/MacOS/Adobe\ AIR\ Installer'
    notifies :create, "ruby_block[check-adobe-air-install]", :immediately
  end
  
  # Unmount Adobe Air dmg
  execute "unmount-adobe-air-installer" do
    command 'hdiutil detach /Volumes/Adobe\ Air'
    only_if File.exist? '/Volumes/Adobe\ Air'
  end
  
  ruby_block "check-adobe-air-install" do
    block do
      runtime_version = `arh -runtimeVersion`.strip
      node['digital_signage']['adobe_air']['installed_version'] = runtime_version
      raise "Adobe Air Installer failed" if runtime_version.length < 1
    end
    action :nothing
  end
  
else
  # Make sure we store the current version Adobe Air version
  ruby_block "save-adobe-air-version" do
    block do
      node['digital_signage']['adobe_air']['installed_version'] = `arh -runtimeVersion`.strip
    end
    action :create
  end
end


