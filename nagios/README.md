Description
===========

Installs and configures Nagios server and NRPE client. This cookbook has been modified from the default to provide features unique to our environment. The following changes have been made:

server.rb
---------
* When using the multi_environment_monitoring option, an array of environments can be specified to limit the scope of the search
* host_name_attribute is ignored; all Nagios hosts are named using the node name
* Search-defined hostgroups use the node name instead of the hostname
* Custom timeperiods are pulled from databags and inserted into timeperiods template
* Custom server plugins can be installed

client.rb
---------

* Installs custom NRPE plugins contained in the plugins directory
* Recipe updated to add custom NRPE checks defined in node attributes

client_windows.rb
---------

* New recipe for installing and configuring NSClient++ on Windows

server_extras.rb
---------

* New recipe for installing Exfoliation theme and host platform logos

splunk.rb
---------

* New recipe for configuring Splunk forwarder and installing MK Livestatus

commands.cfg.erb
----------------

* Template updated with performance data commands needed for Splunk app

hosts.cfg.erb
-------------

* host_name_attribute is ignored; all Nagios hosts are named using the node name
* Search-based hosts are defined
* Unmanaged hosts are named using the "host_name" attribute instead of the ID, since Chef does not allow dots in the ID

hostextinfo.cfg.erb
-------------

* New template for extended host information, used by the server_extras.rb recipe

livestatus.erb
-------------

* New template for livestatus xinet daemon configuration

nagios.cfg.erb
----------------

* Template updated with options needed for Splunk app

nsclient.ini.erb
----------------

* New template for NSClient++ configuration file, used by the client_windows.rb recipe

services.cfg.erb
----------------

* Removed checks for existing hostgroups to allow a comma separated list of hostgroups

templates.cfg.erb
----------------

* Template updated to enable performance data collection for default hosts and services

timeperiods.cfg.erb
----------------

* Template updated to allow custom timeperiods defined in databags