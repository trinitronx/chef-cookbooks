Description
===========

This cookbook automates the deployment and configuration of tftpd-hpa, an easy to configure TFTP server.

Requirements
============

Currently only tested on Ubuntu 12.04, but should work on any modern Ubuntu distribution.

Attributes
==========

default attributes
------------------

* `node[tftpd-hpa']['tftp_directory']` - Location for the tftpd-hpa configuration file

Recipes
=======

default
-------

The default recipe performs four functions:

* Installs the tftpd-hpa package
* Sets up the service and enables it
* Creates a world-readable TFTP directory
* Updates the tftpd-hpa configuration file using the tftpd-hpa.erb template and restarts the service

Usage
=====

Either add the default recipe to the run list of a node, or create a role.