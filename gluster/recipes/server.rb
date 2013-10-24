#
# Cookbook Name:: gluster
# Recipe:: server
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

# Include the repository recipe to pull in 3.4 packages
include_recipe "gluster::repository"

# Install the server package
package "glusterfs-server"

# Loop through each configured partition
bricks = Array.new
node['gluster']['server']['partitions'].each do |p|
	# If a partition doesn't exist, create it
	if `fdisk -l 2> /dev/null | grep '#{p}'`.empty?
		# Pass commands to fdisk to create a new partition
		bash "create partition" do
			code "(echo n; echo p; echo 1; echo; echo; echo w) | fdisk #{p.gsub(/[0-9]/i, '')}"
			action :run
		end
		
		# Format the new partition
		execute "format partition" do
			command "mkfs.ext4 #{p}"
			action :run
		end
	end

	# Create a mount point
	directory "#{node['gluster']['server']['brick_mount_path']}/#{p.sub('/dev/', '')}" do
		recursive true
		action :create
	end

	# Mount the partition and add to /etc/fstab
	mount "#{node['gluster']['server']['brick_mount_path']}/#{p.sub('/dev/', '')}" do
		device p
		fstype "ext4"
		action [:mount, :enable]
	end

	# Create a directory to use as a brick for each configured volume
	node['gluster']['server']['volumes'].each do |volume_name, volume_values|
		# If the node is configured as a peer for the volume, create the directory
		if volume_values['peers'].include? node['fqdn']
			directory "#{node['gluster']['server']['brick_mount_path']}/#{p.sub('/dev/', '')}/#{volume_name}" do
				action :create
			end
			bricks << "#{node['gluster']['server']['brick_mount_path']}/#{p.sub('/dev/', '')}/#{volume_name}"
		end
	end
end

# Save the array of bricks to the node's attributes
node.set['gluster']['server']['bricks'] = bricks

# Create and start volumes
node['gluster']['server']['volumes'].each do |volume_name, volume_values|
	# Only continue if the node is set as the master
	if volume_values['master'] == node['fqdn']
		# Configure the trusted pool if needed
		volume_values['peers'].each do |peer|
			unless peer == node['fqdn']
				execute "gluster peer probe #{peer}" do
					action :run
					not_if "egrep '^hostname.+=#{peer}$' /var/lib/glusterd/peers/*"
				end
			end
		end

		# Create the volume if it doesn't exist
		unless File.exists?("/var/lib/glusterd/vols/#{volume_name}/info")
			# Create a hash of peers and their bricks
			volume_bricks = {}
			brick_count = 0
			volume_values['peers'].each do |peer|
				chef_node = Chef::Node.find_or_create(peer)
				if chef_node['gluster']['server']['bricks']
					peer_bricks = chef_node['gluster']['server']['bricks'].select { |brick| brick.include? volume_name }
					volume_bricks[peer] = peer_bricks
					brick_count += (peer_bricks.count || 0)
				end rescue NoMethodError
			end

			# Create option string
			options = String.new
			case volume_values['volume_type']
			when "distributed-replicated"
				# Ensure the trusted pool has the required number of bricks available
				unless brick_count == (volume_values['replica_count'] * volume_values['peers'].count)
					Chef::Log.warn("Required number of bricks not available for volume #{volume_name}. Skipping...")
					return
				else
					options = "replica #{volume_values['replica_count']}"
					for i in 1..volume_values['replica_count']
						volume_bricks.each do |peer, bricks|
							options << " #{peer}:#{bricks[i-1]}"
						end
					end
				end
			end
			
			execute "gluster volume create #{volume_name} #{options}" do
				action :run
			end
		end

		# Start the volume
		execute "gluster volume start #{volume_name}" do
			action :run
			not_if { `gluster volume info #{volume_name} | grep Status`.include? 'Started' }
		end
	end
end