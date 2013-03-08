Description
===========

This cookbook automates the deployment and configuration of vsftpd, a popular FTP server.

Requirements
============

Currently only tested on Ubuntu 12.04, but should work on any modern Ubuntu distribution.

Attributes
==========

default attributes
------------------

* `node['vsftpd']['conf_file']` - The path to the configuration file
* `node['vsftpd']['anonymous_enable']` - Enable anonymous authentication; defaults to no
* `node['vsftpd']['local_enable']` - Allow local users to log in; defaults to yes
* `node['vsftpd']['write_enable']` - Allow local users to perform any write command; defaults to yes
* `node['vsftpd']['local_umask']` - The default umask for all uploaded files; set to 022
* `node['vsftpd']['userlist_file']` - The path to the list of local users allowed to use FTP
* `node['vsftpd']['userlist_group']` - The group to pull a list of allowed users from; the default recipe will search the "users" databag for any user that has this group specified

Recipes
=======

default
-------

The default recipe performs the following functions:

* Installs the vsftpd package
* Sets up the service and enables it
* Searches the "users" databag for any user accounts that have the group specified in the `node['vsftpd']['userlist_group']` attribute and stores the IDs in an array
* Creates a userlist file using the "vsftpd.user_list.erb" template with the array created
* Updates the vsftpd configuration file using the "vsftpd.conf.erb" template and restarts the service

Usage
=====

Either add the default recipe to the run list of a node, or create a role.