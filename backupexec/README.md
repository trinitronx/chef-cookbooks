Description
===========

This cookbook is created with the aim of automating the deployment of BackupExec agents.

Requirements
============

* Currently only tested on Ubuntu. Ubuntu versions prior to 11.10 are also recommended (likely required) due to incompatibility with the agent itself.

Attributes
==========

Default attribute values:

* None at this time

Usage
=====


Recipes:


[backupexec::ralus]

This recipe will install the BackupExec agent on the node. To use:

* Add the agent installer to the cookbook files/default directory
** Rename the installer to RALUS.tar.gz 
* Add necessary firewall exceptions (i.e. incoming TCP port 10000)
* Apply the recipe to the node

[backupexec::default]
The default recipe will call the [backupexec::agent] recipe



