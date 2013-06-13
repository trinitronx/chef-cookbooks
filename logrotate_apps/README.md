Description
===========
This cookbook leverages the logrotate_app definition in Opscode's cookbook and allows you to create logrotate configurations for apps using the nodes' attributes.

Requirements
============
#### cookbooks
- `logrotate`

Usage
=====
#### logrotate_apps::default
Include `logrotate_apps` in your node's `run_list`. Populate the node's \['logrotate'\]\['apps'\] attribute with an array of hashes for each logrotate configuration to create. See the Opscode logrotate cookbook for an explanation of the logrotate_app definition and associated options.