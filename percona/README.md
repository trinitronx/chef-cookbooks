Description
===========

This cookbook automates the deployment and configuration of Percona XtraDB Cluster. Cluster members are discovered and deployed automatically using a combination of roles and attributes. The cookbook can also set up a node to run HAProxy as a load balancer, and can be combined with Opscode's keepalived cookbook to fail over to another proxy node.

Requirements
============

Currently only tested on Ubuntu 12.04, but should work on any modern Ubuntu distribution.

Recipes
=======

clustercheck.rb
---------------

Installs a script and sets up a MySQL user to provide database monitoring of the cluster member to a proxy such as HAProxy.

haproxy.rb
---------------

Installs and configures HAProxy to provide load balancing and/or failover for XtraDB Cluster members.

repository.rb
---------------

Sets up Percona's apt repository providing binaries for XtraDB Cluster, XtraBackup, etc.

xtradb_cluster.rb
-----------------

Pre-stages MySQL configuration files and installs Percona XtraDB Cluster. Includes the `percona::clustercheck` recipe for an HAProxy host to monitor database functionality. Also optionally installs Percona XtraBackup and sets up a user to provide state transfers between cluster members.

Usage
=====

Server setup
------------

Create roles in Chef to deploy XtraDB Cluster. One role should contain the percona::xtradb recipe and all of the attributes needed to properly set up the host, including MySQL user passwords needed for the root user, the debian-sys-maint user, the clustercheck user, and optionally the user for XtraBackup. The role should also contain firewall exceptions for the ports used by XtraDB Cluster (3306, 4444, 4567, 4568, and 9200) if applicable.

If HAProxy will be load balancing between all of the cluster members, the `node['percona']['cluster_role']` attribute can be set to 'master' in the role created above, and no other roles are needed for the cluster members. The HAProxy host will search for nodes that have this attribute set and will load balance between the cluster members that have the attribute set to 'master.' If HAProxy will be set to use one cluster member for writes and the other nodes as backups for failover, two other distinct roles can be created - a "master" role and a "slave" role with the attribute above set to 'master' or 'slave' respectively.

To deploy the HAProxy host, another role should be created containing the percona::haproxy recipe and any attributes that need to be changed from the defaults. This recipe can also be combined with the keepalived cookbook from Opscode to provide failover for HAProxy. The keepalived attributes can be included in this role to deploy the two services together.

Once the roles have been created, the nodes should be deployed in order: the XtraDB cluster member to be used for writing, the other cluster members, and finally the HAProxy host and optionally a secondary HAProxy slave host.