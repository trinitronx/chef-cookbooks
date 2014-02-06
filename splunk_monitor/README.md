Description
===========

This cookbook extends the splunk cookbook to add variables for controlling which data sources are monitored and forwarded. It is dependent on the splunk cookbook.

Notes:
* Splunk universal forwarder package installation creates a "splunk" user with a uid incremented by one above the highest existing uid. If you are managing uid's with another system (e.g. a chef-user's cookbook), this can conflict with existing or future uid's.  Accordingly, this cookbook will systematically delete the "splunk" user each time it is run, and is hardcoded to run the Splunk Universal Forwarder as root.

Requirements
============

 ['splunk' cookbook](https://github.com/bestbuycom/splunk_cookbook)

Attributes
==========

\[splunk\]\[monitors\] : The default recipe will look for this attribute as an array, with each index formatted as a hash. Each hash's key serves as a short name for a monitor to configure, and its value should be a hash of attributes for the monitor. In these "sub-hashes", a 'location' hash (specificying the file or directory to be monitored) is required; 'index', 'sourcetype', or 'hostname' hashs are optional.

\[splunk\]\[hostname\_source\] : Optional attribute to override the host field forwarded by splunk. Set the atribute to the value 'node\_name' to use the node's node name (by default the node's fqdn) as the default host field in Splunk forwarded events.

\[splunk\]\[transforms\] : Optional attribute to set transforms entries. Expected to be an array, with each index formatted as a hash. Each hash's key serves as the stanza name for the transform, and its value should be a hash of attributes for the transform. In these "sub-hashes", 'regex', 'format', and 'dest\_key' hashes are required (for the transforms.conf file).

\[splunk\]\[props\] : Optional attribute to set props.conf entries to put the above transforms into effect. Expected to be an array, with each index formatted as a hash. Each hash's key serves as the spec for the transform, and its value should be a hash of attributes for the spec. In these "sub-hashes", 'class' and 'transforms\_stanza' hashes are required (for the transforms.conf file).

*transforms & props naming referenced from http://docs.splunk.com/Documentation/Splunk/latest/Data/overridedefaulthostassignments*

Usage
=====

Same dependencies as the splunk::forwarder recipe:

\* One or more splunk servers (that will be receiving the data) need to have the "splunk-server" role attached to them (the role can be empty; simply used by the forwarders to programatically find splunk servers)
\* Attributes for the splunk cookbook need to be defined; minimally:
>     [splunk][server_config_folder] (e.g. prod)
>     [splunk][forwarder_config_folder] (e.g. prod)
>     [splunk][auth] (e.g. admin:securepassword)
>     [splunk][forwarder_role] (e.g. whatever template folder name)
>     [splunk][indexer_name] (e.g. name for the indexer splunk.biola.edu)

\* Add a 'monitors' array to node[splunk]. Populate it with 1 or more values. The following is an example from a knife role edit:
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
>            "blacklist": "", #optional
>            "crcSalt": "" #optional
>          }
>        }
>      ],
> ...

\* Finally, apply the splunk\_monitor::default recipe to the role/node.

# Additional Recipes #

\* The [splunk\_monitor::biolasecuritymonitoring] recipe will install the "TA-biola\_security\_monitoring" technology add-on into splunk. See the [technology add-on's homepage](https://github.com/biola/ta-biola_security_monitoring) for more information.
\* The [splunk\_monitor::vmwareapp] recipe will install and configure the [Splunk App for VMware](http://splunk-base.splunk.com/apps/28423/splunk-app-for-vmware). Apply this to your indexers, and apply attributes to them to indicate a URL for downloading the app zip/tgz
\* The [splunk\_monitor::vcenter\_ta] recipe accompanies the vmwareapp recipe. Apply it to your vCenter host nodes to run after the Splunk UF is installed
\* The [splunk\_monitor::imagenow\_ta] recipe will install a technology add-on onto a Windows node and periodically poll an ImageNow server for license usage
