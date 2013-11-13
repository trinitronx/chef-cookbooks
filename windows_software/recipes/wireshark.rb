#
# Cookbook Name:: windows_software
# Recipe:: wireshark
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

if node['platform'] == "windows" then

  include_recipe "windows::default"

  unless node['windows_software']['wireshark']['winpcap_url'] == 'changeme'
    windows_package node['windows_software']['wireshark']['winpcap_displayname'] do
      source node['windows_software']['wireshark']['winpcap_url']
      if node['windows_software']['wireshark']['winpcap_checksum']
        checksum node['windows_software']['wireshark']['winpcap_checksum']
      end
      installer_type :custom
      options '/S'
      action :install
    end
  end

  unless node['kernel']['machine'] == "i386" && node['windows_software']['wireshark']['download_url_32bit'] != "changeme"

    unless node['windows_software']['wireshark']['download_url'] == 'changeme'
      windows_package node['windows_software']['wireshark']['displayname'] do
        source node['windows_software']['wireshark']['download_url']
        if node['windows_software']['wireshark']['checksum']
          checksum node['windows_software']['wireshark']['checksum']
        end
        installer_type :custom
        options '/NCRC /S /desktopicon=no /quicklaunchicon=no'
        action :install
      end
    end

  else

    unless node['windows_software']['wireshark']['download_url_32bit'] == 'changeme'
      windows_package node['windows_software']['wireshark']['displayname_32bit'] do
        source node['windows_software']['wireshark']['download_url_32bit']
        if node['windows_software']['wireshark']['checksum_32bit']
          checksum node['windows_software']['wireshark']['checksum_32bit']
        end
        installer_type :custom
        options '/NCRC /S /desktopicon=no /quicklaunchicon=no'
        action :install
      end
    end

  end
end
