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

# installs supplementary required packages for Oracle

['binutils','elfutils-libelf','elfutils-libelf-devel','gcc','gcc-c++','glibc-common','glibc-headers','ksh','libstdc++-devel','make','sysstat'].each do |packagename|
  yum_package packagename
end

# These packages need their i386 version installed as well 
multiarchpackages = ['compat-libstdc++-33','glibc-devel','libaio','libaio-devel','libgcc','libstdc++','unixODBC','unixODBC-devel']

# glibc needs to specifically have the i686 version
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
  multiarchpackages.each do |packagename|
    ['x86_64','i386'].each do |architecture|
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
