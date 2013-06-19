#
# Cookbook Name:: vncserver
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

case node['platform_family']
when "rhel"

  # Install the X11 package group
  execute "x11installation" do
    command "yum groupinstall -y 'X Window System'"
    creates "/usr/bin/startx"
  end

  # Add internet browsers
  execute "browserinstallation" do
    if node['platform_version'].to_i >= 6
      command "yum groupinstall -y 'Internet Browser'"
    else
      command "yum groupinstall -y 'Graphical Internet'"
    end
    creates "/usr/bin/firefox"
  end

  # Regular packages to install
  ['vnc-server','xterm','twm'].each do |packagename|
    yum_package packagename
  end

  # Packages needed on RHEL6+
  # On RHEL6.4 x64, twm will fail to start without
  # liberation-mono-fonts package
  if node['platform_version'].to_i >= 6
    yum_package 'liberation-mono-fonts'
  end

end
