Description
===========

Installs and configures Nagios server and NRPE client. This cookbook has been modified from the default to provide features unique to our environment. The following changes have been made:

server.rb
---------
* host_name_attribute is ignored; all Nagios hosts are named using the node name
* Search-defined hostgroups use the node name instead of the hostname
* Custom timeperiods are pulled from databags and inserted into timeperiods template

client.rb
---------

* Recipe updated to add custom NRPE checks defined in node attributes

hosts.cfg.erb
-------------

* host_name_attribute is ignored; all Nagios hosts are named using the node name

services.cfg.erb
----------------

* Removed checks for existing hostgroups to allow a comma separated list of hostgroups

timeperiods.cfg.erb
----------------

* Template updated to allow custom timeperiods defined in databags