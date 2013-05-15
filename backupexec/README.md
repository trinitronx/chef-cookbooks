Description
===========

This cookbook is created with the aim of automating the deployment of BackupExec agents.

Requirements
============

*  RALUS currently only tested on Ubuntu. Ubuntu versions prior to 11.10 are also recommended (likely required) due to incompatibility with the agent itself.
*  RAWS should work properly with Windows 7+ systems (and Windows 2003/xp if the AOFO isn't needed)

Attributes
==========

For RAWS, the node\["backupexec"\]\["rawsx64url"\] attribute & node\["backupexec"\]\["raws32url"\] attributes should be set to the URL hosting the zipped up RAWS install files

Usage
=====


Recipes:


[backupexec::ralus]

This recipe will install the BackupExec agent on the node. To use:

* Add the agent installer to the cookbook files/default directory
** Rename the installer to RALUS.tar.gz 
* Add necessary firewall exceptions (i.e. incoming TCP port 10000)
* Apply the recipe to the node

[backupexec::raws]
Will install the RAWS on Windows systems. To use:

* Update the url attributes (see URL section)
* Apply the recipe to the node



