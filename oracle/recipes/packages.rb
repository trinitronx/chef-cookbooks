#
# Cookbook Name:: oracle
# Recipe:: packages
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

  # installs supplementary required packages for Oracle
  #
  # This could be reduced to ['make','binutils','gcc','libaio','glibc-common','libstdc++','libXtst','sysstat','glibc'] for Enterprise Manager (plus the i686 version of glibc-devel), but just leaving one single list here for simplicity

  ['binutils','elfutils-libelf','elfutils-libelf-devel','gcc','gcc-c++','glibc-common','glibc-headers','ksh','libstdc++-devel','make','sysstat','libXtst'].each do |packagename|
    yum_package packagename
  end

  # Special exceptions here for RHEL 5/6
  if node['platform_version'].to_i >= 6
    yum_package 'mksh'
  else
    yum_package 'pdksh'
  end

  # These packages need their i386 (on RHEL5) or i686 (RHEL6+) version installed as well 
  multiarchpackages = ['compat-libstdc++-33','glibc-devel','libaio','libaio-devel','libgcc','libstdc++','unixODBC','unixODBC-devel','openmotif','openmotif22']

  # glibc needs to specifically have the i686 version on RHEL5
  isixeightysixpackages = ['glibc']

  if node['kernel']['machine'] == "i686"
    multiarchpackages.each do |packagename|
      yum_package packagename
    end
  
    isixeightysixpackages.each do |packagename|
      yum_package packagename
    end

  # Since the machine has been determined to not be 32bit
  # This should probably be changed to a 64bit check
  else
    if node['platform_version'].to_i >= 6
      archlist = ['x86_64','i686']
    else
      archlist = ['x86_64','i386']
    end
      
    multiarchpackages.each do |packagename|
      archlist.each do |architecture|
        yum_package packagename do
          arch architecture
        end
      end
    end

    isixeightysixpackages.each do |packagename|
      ['x86_64','i686'].each do |architecture|
        yum_package packagename do
          arch architecture
        end
      end
    end
  end
end
