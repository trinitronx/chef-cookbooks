gluster Cookbook
================
This cookbook is used to install and configure Gluster on both servers and clients. This cookbook makes several assumptions when configuring Gluster servers:

1. Each disk will contain a single partition dedicated for Gluster; LVM is not used
2. Each configured partition will be formatted with the ext4 filesystem rather than the recommended xfs filesystem to allow partitions to be resized (xfs filesystems cannot be resized on Ubuntu 12.04 systems without a newer kernel installed)
3. Gluster volumes will share the configured partitions and will not have their own dedicated storage
4. All peers for a volume will be configured with the same number of bricks

Requirements
------------
This cookbook requires Ubuntu version 12.04 or higher. All testing has been performed on Ubuntu 12.04.

Attributes
----------

#### gluster::client
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['gluster']['client']['volumes'][VOLUME_NAME]['server']</tt></td>
    <td>String</td>
    <td>Server to connect to</td>
    <td>None</td>
  </tr>
  <tr>
    <td><tt>['gluster']['client']['volumes'][VOLUME_NAME]['mount_point']</tt></td>
    <td>String</td>
    <td>Mount point to use for the Gluster volume</td>
    <td>None</td>
  </tr>
</table>

#### gluster::server
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['gluster']['server']['volumes']['brick_mount_path']</tt></td>
    <td>String</td>
    <td>Default path to use for mounting bricks</td>
    <td>None</td>
  </tr>
  <tr>
    <td><tt>['gluster']['server']['partitions']</tt></td>
    <td>Array</td>
    <td>An array of partitions to create and format for use with Gluster, such as '/dev/sdb1'</td>
    <td>None</td>
  </tr>
  <tr>
    <td><tt>['gluster']['server']['volumes'][VOLUME_NAME]['master']</tt></td>
    <td>String</td>
    <td>The FQDN of the server used as the 'master' peer; used to run Gluster commands</td>
    <td>None</td>
  </tr>
  <tr>
    <td><tt>['gluster']['server']['volumes'][VOLUME_NAME]['peers']</tt></td>
    <td>Array</td>
    <td>An array of FQDNs for peers used in the volume</td>
    <td>None</td>
  </tr>
  <tr>
    <td><tt>['gluster']['server']['volumes'][VOLUME_NAME]['replica_count']</tt></td>
    <td>Integer</td>
    <td>The number of replicas to create</td>
    <td>None</td>
  </tr>
  <tr>
    <td><tt>['gluster']['server']['volumes'][VOLUME_NAME]['volume_type']</tt></td>
    <td>String</td>
    <td>The volume type to use; currently 'distributed replicated' is the only type supported</td>
    <td>None</td>
  </tr>
</table>

Usage
-----

On two or more identical systems, attach the desired number of dedicated disks to use for Gluster storage. Create a role containing the gluster::server recipe for the gluster peers to use and add the appropriate partitions to the `['gluster']['server']['partitions']` attribute and any volumes to the `['gluster']['server']['volumes']` attribute. Once all peers for a volume have configured their bricks, the 'master' peer will create and start the volume.

For clients, create a role containing the gluster::default or gluster::client recipe, and add any volumes to mount to the `['gluster']['client']['volumes']` attribute. The Gluster volume will be mounted on the next chef-client run (provided the volume exists and is available) and added to /etc/fstab.