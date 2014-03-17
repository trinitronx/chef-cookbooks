#
# Cookbook Name:: bacula
# Recipe:: hardwarecompression
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

# GNU mt doesn't support the needed command here
# https://wiki.zmanda.com/index.php/Hardware_compression
e = package 'mt-st' do
  action :nothing
end
e.run_action(:install)

if node['bacula']['sd']['hardware_compression_devices']
  node['bacula']['sd']['hardware_compression_devices'].each do |tapedrive|
    cmd = Mixlib::ShellOut.shell_out!("cat /sys/class/scsi_tape/#{tapedrive}/default_compression")
    if cmd.stdout =~ /-1/
      # No default mode set; enabling
      compcommand = Mixlib::ShellOut.shell_out!("mt-st -f /dev/#{tapedrive} defcompression 1")
    end
  end
end
