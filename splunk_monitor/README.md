Description
===========

This cookbook extends the chef-splunk and chef-splunk-windows cookbooks to add variables for controlling which data sources are monitored and forwarded. It is dependent on the chef-splunk and chef-splunk-windows cookbooks.

Requirements
============

 ['chef-splunk' cookbook](https://supermarket.getchef.com/cookbooks/chef-splunk)
 ['chef-splunk-windows' cookbook](https://github.com/biola/chef-cookbooks/tree/master/chef-splunk-windows)

Attributes
==========

\[splunk\]\[monitors\] : The default recipe will look for this attribute as an array, with each index formatted as a hash. Each hash's key serves as a short name for a monitor to configure, and its value should be a hash of attributes for the monitor. In these "sub-hashes", a 'location' hash (specificying the file or directory to be monitored) is required; 'index', 'sourcetype', or 'hostname' hashs are optional.

\[splunk\]\[hostname\_source\] : Optional attribute to override the host field forwarded by splunk. Set the atribute to the value 'node\_name' to use the node's node name (by default the node's fqdn) as the default host field in Splunk forwarded events.

\[splunk\]\[transforms\] : Optional attribute to set transforms entries. Expected to be an array, with each index formatted as a hash. Each hash's key serves as the stanza name for the transform, and its value should be a hash of attributes for the transform. In these "sub-hashes", 'regex', 'format', and 'dest\_key' hashes are required (for the transforms.conf file).

\[splunk\]\[props\] : Optional attribute to set props.conf entries to put the above transforms into effect. Expected to be an array, with each index formatted as a hash. Each hash's key serves as the spec for the transform, and its value should be a hash of attributes for the spec. In these "sub-hashes", 'class' and 'transforms\_stanza' hashes are required (for the transforms.conf file).

*transforms & props naming referenced from http://docs.splunk.com/Documentation/Splunk/latest/Data/overridedefaulthostassignments*

Usage
=====

\* Add a 'monitors' array to node[splunk]. Populate it with 1 or more values. The following is an example from a knife role edit:
>  "override_attributes": {
>    "splunk": {
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
