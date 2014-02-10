#
# Cookbook Name:: oracle
# Recipe:: icu
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

case node['platform_family']
when "rhel"
  # These packages need their i386 (on RHEL5) or i686 (RHEL6+) version installed as well 
  multiarchpackages = ['libicu', 'libicu-devel']
  if node['kernel']['machine'] == "i686"
    multiarchpackages.each do |packagename|
      yum_package packagename
    end
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
  end
end
