#
# Cookbook Name:: cobol
# Recipe:: microfocus
#
# Copyright 2014, Biola University 
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

include_recipe 'ark::default'
# 'Expect' support
chef_gem 'greenletters'

directory "/opt/microfocus/cobol" do
  recursive true
  action :create
end

# Server Express install
ark "cobol" do
  url node['cobol']['microfocus']['download_url']
  checksum node['cobol']['microfocus']['download_checksum']
  path '/opt/microfocus'
  strip_components 0
  action :put
end

ruby_block "install mf cobol" do
  block do
    require 'greenletters'
    installer = Greenletters::Process.new("/opt/microfocus/cobol/install", :transcript => $stdout)
    installer.start!
    installer.wait_for(:output, /Do you wish to continue \(y\/n\):/i)
    installer << "y\n"
    installer.wait_for(:output, /Do you agree to the terms of the License Agreement\? \(y\/n\):/i)
    installer << "y\n"
    installer.wait_for(:output, /Please confirm that you want to continue with this installation \(y\/n\):/i)
    installer << "y\n"
    installer.wait_for(:output, /Please press return when you are ready:/i)
    installer << "\n"
    sleep 1
    installer << "q"
    #installer.wait_for(:output, /Please confirm your understanding of the above reference environment details \(y\/n\):/i)
    installer.wait_for(:output, /details \(y\/n\):/i)
    installer << "y\n"
    installer.wait_for(:output, /Do you want to make use of COBOL and Java working together\? \(y\/n\):/i)
    installer << "n\n"
    installer.wait_for(:output, /Would you like to install LMF now\? \(y\/n\):/i)
    installer << "y\n"
    installer.wait_for(:output, /\(Press Enter for default directory \/opt\/microfocus\/mflmf\)/i)
    installer << "\n"
    installer.wait_for(:output, /do you wish to create it \? \(y\/n\)/i)
    installer << "y\n"
    installer.wait_for(:output, /Do you want only superuser to be able to access the License Admin System\? \(y\/n\)/i)
    installer << "y\n"
    installer.wait_for(:output, /Do you want license manager to be automatically started at boot time\? \(y\/n\)/i)
    installer << "y\n"
    installer.wait_for(:output, /Please enter either 32 or 64 to set the system default mode:/i)
    installer << "#{node['cobol']['microfocus']['default_system_mode']}\n"
    installer.wait_for(:output, /Do you wish to configure Enterprise Server now\? \(y\/n\):/i)
    installer << "n\n"
    installer.wait_for(:output, /Do you want to install XDB\? \(y\/n\):/i)
    installer << "n\n"
    installer.wait_for(:exit)
  end
  not_if do ::File.directory?('/opt/microfocus/mflmf') end
end

# Start the license manager during the inital install
execute '/etc/mflmrcscript' do
  not_if do ::File.directory?('/opt/microfocus/mflmf') end
end

# Setup environment variables
template '/etc/profile.d/mfcobol.sh' do
  mode 0755
end

# install EXPRESS license keys
unless node['cobol']['microfocus']['express_license_installed']
  ruby_block "install mf cobol express license keys" do
    block do
      require 'greenletters'
      Dir.chdir '/opt/microfocus/mflmf'
      installer = Greenletters::Process.new("/opt/microfocus/mflmf/mflmcmd", :transcript => $stdout)
      installer.start!
      installer.wait_for(:output, /Enter 'U'/i)
      installer << "i\n"
      installer.wait_for(:output, /Key:/i)
      sleep 1
      installer << "#{node['cobol']['microfocus']['express_serial_number']}\n"
      installer.wait_for(:output, /Key:/i)
      sleep 1
      installer << "#{node['cobol']['microfocus']['express_license_key']}\n"
      installer.wait_for(:exit)
    end
  end
  node.set['cobol']['microfocus']['express_license_installed'] = true
end

# install app license keys
unless node['cobol']['microfocus']['user_license_installed']
  ruby_block "install mf cobol user license keys" do
    block do
      require 'greenletters'
      Dir.chdir '/opt/microfocus/cobol/aslmf'
      installer = Greenletters::Process.new("/opt/microfocus/cobol/aslmf/apptrack", :transcript => $stdout)
      installer.start!
      installer.wait_for(:output, /password\)/i)
      installer << "      "
      installer.wait_for(:output, /password/i)
      installer << "      "
      installer.wait_for(:output, /Selection/i)
      installer << "3"
      installer.wait_for(:output, /Key:/i)
      installer << "#{node['cobol']['microfocus']['user_serial_number']}\n"
      installer.wait_for(:output, /Key:/i)
      installer << "#{node['cobol']['microfocus']['user_license_key']}\n"
      installer.wait_for(:output, /Selection/i)
      installer << "9"
      installer.wait_for(:exit)
    end
  end
  node.set['cobol']['microfocus']['user_license_installed'] = true
end
