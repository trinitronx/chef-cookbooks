#
# Cookbook Name:: netatalk_biola
# Recipe:: default
#
# Copyright 2013, Biola University 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

remote_file "#{Chef::Config[:file_cache_path]}/netatalk-3.1-beta2.tar.gz" do
  source "http://sourceforge.net/projects/netatalk/files/netatalk/3.1/netatalk-3.1-beta2.tar.gz/download"
  checksum 'e4ddd0b28a7892b0c9392ac9c40a85d33c771aef7f3e21ca8da9d63402e3576b'
end

# Install Tracker binaries
# Skipping recommended packages (GUI components)
package "tracker" do
  options "--no-install-recommends"
end

# Other tracker packages
trackerPkgs = ['dbus','libdbus-1-dev','libdbus-glib-1-dev','libtracker-sparql-0.14-dev','libtracker-miner-0.14-dev','tracker-miner-fs','tracker-utils']
trackerPkgs.each do |i|
  package i
end

# Netatalk dependencies
# http://netatalk.sourceforge.net/3.1/htmldocs/installation.html)
# http://netatalk.sourceforge.net/wiki/index.php/Install_Netatalk_3.0.5_on_Ubuntu_13.04_Raring
netatalkPkgs = ['build-essential','libdb-dev','libgcrypt11-dev','libssl-dev','libpam0g-dev','libwrap0-dev','libevent-dev']
netatalkPkgs.each do |i|
  package i
end

unless File.exist?("/usr/local/sbin/netatalk")
  # Installing netatalk
  # ignoring the static libevent in favor of the system bundled version
  bash "install netatalk from source" do
    user "root"
    cwd "#{Chef::Config[:file_cache_path]}"
    code <<-EOH
      tar -zxf netatalk-3.1-beta2.tar.gz
      (cd netatalk-3.1-beta2/ && ./configure --with-init-style=debian --with-tracker-pkgconfig-version=0.14 --without-libevent && make && make install)
    EOH
  end

  execute "update-rc.d netatalk defaults 50"
end

# Setup root's profile, so that tracker commands can be run
# Without manually updating the environment variables
unless File.readlines("/root/.profile").grep(/DBUS_SESSION_BUS_ADDRESS/).size > 0
  execute "echo 'NETATALKPREFIX=\"/usr/local\"' >> /root/.profile"
  execute "echo 'export XDG_DATA_HOME=\"$NETATALKPREFIX/var/netatalk/\"' >> /root/.profile"
  execute "echo 'export XDG_CACHE_HOME=\"$NETATALKPREFIX/var/netatalk/\"' >> /root/.profile"
  execute "echo 'export DBUS_SESSION_BUS_ADDRESS=\"unix:path=$NETATALKPREFIX/var/netatalk/spotlight.ipc\"' >> /root/.profile"
end

# Bundled configuration file doesn't support reload; adjusting it here
template "/etc/init.d/netatalk" do
  source "netatalk.initd.erb"
  mode 0755
  owner "root"
  group "root"
end
