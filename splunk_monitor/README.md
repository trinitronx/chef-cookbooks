Description
===========

This cookbook extends the splunk cookbook to add variables for controlling which data sources are monitored and forwarded. It is dependent on the splunk cookbook.

Requirements
============

 'splunk' cookbook (https://github.com/bestbuycom/splunk_cookbook)

Attributes
==========

[splunk][monitors] : The default recipe will look for this attribute as an array, with each index formatted as a hash. Each hashes key serves as a short name for a monitor to configure, and its value should be a hash of attributes for the monitor. In these "sub-hashes", a 'location' hash (specificying the file or directory to be monitored) is required; an 'index' and/or 'sourcetype' hash[s] are optional.

Usage
=====

Same dependencies as the splunk::forwarder recipe:

* One or more splunk servers (that will be receiving the data) need to have the "splunk-server" role attached to them (the role can be empty; simply used by the forwarders to programatically find splunk servers)
* Attributes for the splunk cookbook need to be defined; minimally:

#     [splunk][server_config_folder] (e.g. prod)
#     [splunk][forwarder_config_folder] (e.g. prod)
#     [splunk][auth] (e.g. admin:securepassword)
#     [splunk][forwarder_role] (e.g. whatever template folder name)
#     [splunk][indexer_name] (e.g. name for the indexer splunk.biola.edu)

* Add a 'monitors' array to node[splunk]. Populate it with 1 or more values. The following is an example from a knife role edit:

>  "override_attributes": {
>    "splunk": {
>      "server_config_folder": "prod",
>      "forwarder_config_folder": "prod",
>      "monitors": [
>        {
>          "thisistheshortlogname": {
>            "location": "/var/log/fileordirectory",
>            "index": "couldomitthis",
>            "sourcetype": "", #optional
>            "whitelist": "", #optional
>            "blacklist": "" #optional
>          }
>        }
>      ],
> ...

* Finally, apply the splunk_monitor::default recipe to the role/node.
