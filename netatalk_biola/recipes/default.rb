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

# TODO - breakout version number into attributes

remote_file "#{Chef::Config[:file_cache_path]}/netatalk-3.1.0.tar.gz" do
  source "http://sourceforge.net/projects/netatalk/files/netatalk/3.1/netatalk-3.1.0.tar.gz/download"
  checksum 'd1ebcf5fad0185a8e9ea541edf3be57e3a833e9a803caa487677a209bc3a7042'
end

# Install Tracker binaries
# Skipping recommended packages (GUI components)
package "tracker" do
  options "--no-install-recommends"
end

# Other tracker & afpstats packages
trackerPkgs = ['dbus','libdbus-1-dev','libdbus-glib-1-dev','libtracker-sparql-0.14-dev','libtracker-miner-0.14-dev','tracker-miner-fs','tracker-utils']
trackerPkgs.each do |i|
  package i
end

# Netatalk dependencies
# http://netatalk.sourceforge.net/3.1/htmldocs/installation.html)
# http://netatalk.sourceforge.net/wiki/index.php/Install_Netatalk_3.0.5_on_Ubuntu_13.04_Raring
netatalkPkgs = ['build-essential','libdb-dev','libgcrypt11-dev','libssl-dev','libpam0g-dev','libwrap0-dev','libevent-dev','libcrack2-dev','libpam-cracklib','libavahi-client-dev','libacl1-dev','libldap2-dev']
netatalkPkgs.each do |i|
  package i
end

# Install time
# Setting system config directory to normal /etc instead of /usr/local/etc (makes pam/dbus components work OOTB)
# (could instead omit this and do something like 'cp /usr/local/etc/dbus-1/system.d/netatalk-dbus.conf /etc/dbus-1/system.d/ \
# && service dbus reload')
unless File.exist?("/usr/local/sbin/netatalk")
  # Installing netatalk
  # ignoring the static libevent in favor of the system bundled version
  bash "install netatalk from source" do
    user "root"
    cwd "#{Chef::Config[:file_cache_path]}"
    code <<-EOH
      tar -zxf netatalk-3.1.0.tar.gz
      (cd netatalk-3.1.0/ && ./configure --with-init-style=debian --with-tracker-pkgconfig-version=0.14 --without-libevent --with-cracklib --sysconfdir=/etc && make && make install)
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
# TODO - make version number adjustment automatic
template "/etc/init.d/netatalk" do
  source "netatalk.initd.erb"
  mode 0755
  owner "root"
  group "root"
end
