#
# Cookbook Name:: zfs_linux
# Recipe:: build_tools
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

# Setup pre-reqs

case node['platform_family']
when "rhel"
  # Setup required packaged from the Development Tools group
  ['autoconf', 'automake', 'binutils', 'bison', 'flex', 'gcc', 'gcc-c++', 'gettext', 'libtool', 'make', 'patch', 'pkgconfig', 'redhat-rpm-config', 'rpm-build'].each do |rheldevtool|
    package rheldevtool
  end
  # Additional required packages
  # http://zfsonlinux.org/generic-rpm.html
  ['zlib-devel', 'libuuid-devel', 'libblkid-devel', 'libselinux-devel', 'parted', 'lsscsi', 'wget', 'dkms', 'git', 'kernel-devel', 'kernel-headers'].each do |moredevtools|
    package moredevtools
  end
when 'debian'
  if node['platform_version'].to_f >= 12.04
    prereqpkgs = ['build-essential', 'gawk', 'alien', 'fakeroot', 'zlib1g-dev', 'uuid-dev', 'libblkid-dev', 'libselinux-dev', 'parted', 'lsscsi', 'wget', 'automake', 'libtool', 'git']
    if node['platform_version'] == '12.04'
      prereqpkgs << 'linux-headers-server'
    else
      prereqpkgs << 'linux-headers-generic'
    end
    # Install pre-reqs
    prereqpkgs.each do |pkg|
      package pkg
    end
    # linux-headers package could depend on a newer version of this package;
    # explicity install the version for the current kernel just in case
    krnvercmd = Mixlib::ShellOut.new('uname -r')
    krnvercmd.run_command
    krnver = krnvercmd.stdout.chomp
    unless File.directory?("/usr/src/linux-headers-#{krnver}")
      package "linux-headers-#{krnver}"
    end
  end
end
