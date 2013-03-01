Description
===========
Deploys the splunk forwarder on Windows hosts.


Requirements
============
- `windows` cookbook from Opscode


Attributes
==========
- `['splunk']['indexer_name'] - Sets the receiving indexer for the node.
- `['splunk']['receiver_port'] - Sets the receiving port on the indexer
- `['splunk']['forwarder_install_opts']` - Sets the parameters passed to the installer, excluding the indexer/port (set with the attributes above). Defaults to

        "AGREETOLICENSE=Yes WINEVENTLOG_APP_ENABLE=1 WINEVENTLOG_SEC_ENABLE=1 WINEVENTLOG_SYS_ENABLE=1 WINEVENTLOG_SET_ENABLE=1 PERFMON=cpu,memory,network,diskspace MIGRATESPLUNK=1"


Usage
=====

1. Configure the node/role with the forwarder's necessary attributes (see above)
2. Apply the default recipe to the node. This will silently install the Splunk forwarder and configure the forwarder (with your defined attributes).