Description
===========

Installs and configures Nagios server and NRPE client. This cookbook has been modified from the default to provide features unique to our environment. The following changes have been made:

server.rb
---------
* Line 123, 132: host_name_attribute is ignored; all Nagios hosts are named using the node name
* Line 172, 176: Search-defined hostgroups use the node name instead of the hostname

client.rb
---------

* Line 67: Recipe updated to add custom NRPE checks defined in node attributes

hosts.cfg.erb
-------------

* Line 9, 32: host_name_attribute is ignored; all Nagios hosts are named using the node name

services.cfg.erb
----------------

* Line 17: Removed checks for existing hostgroups to allow a comma separated list of hostgroups