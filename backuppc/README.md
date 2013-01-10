Description
===========
A (fairly simple) recipe for setting up the BackupPC enterprise backup software.

Currently only tested on Ubuntu.


Requirements
============
htpasswd cookbook (https://github.com/Youscribe/htpasswd-cookbook)

Attributes
==========

[backuppc][server][webadminpassword] : setting this attribute will define the backuppc user web admin password

Usage
=====

Apply the backuppc::server recipe to your node, and specify the webadminpassword variable on the node. The BackupPC web admin console will then be available on the server at http://ipaddress/backuppc
