#
# Cookbook Name:: zfs_linux
# Recipe:: snapshot-pruning
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

# Only put the pruning schedules in place if the appropriate attributes
# have been set
if node['zfs']
  if node['zfs']['filesystems'].respond_to?(:each)
    node['zfs']['filesystems'].each do |filesystem|
      filesystem.each do |fkey, fvalue|
        if fvalue['snapshot_retention'].respond_to?(:each)
          fvalue['snapshot_retention'].each do |skey,svalue|
            template "/etc/cron.daily/zfs-auto-prune-#{fvalue['zpool']}-#{fkey.to_s}-#{skey}" do
              source "zfs-auto-prune.erb"
              mode 0755
              variables({
                :filesystem => "#{fvalue['zpool']}/#{fkey.to_s}",
                :snapshot_interval => skey,
                :snapshot_retention => svalue
              })
            end
          end
        end
      end
    end
  end
end
