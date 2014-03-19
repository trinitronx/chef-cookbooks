Description
===========

This cookbook leverages the registry_key resource to manage Windows registry entries via the nodes' attributes.

Requirements
============

Windows Server 2003 and above is supported. Chef 11.6.0 and above is required.

Recipes
=======

default
-------

Pulls entries from the node's \['windows'\]\['registry'\] attribute and adds/removes/updates the entries accordingly. 

Usage
=====

Either add the specific recipe(s) to the run list of a node, or create a role.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[windows_registry]"
  ],
  "default_attributes": {
    "windows": {
      "registry": [
        {
        	"key_name": "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\name_of_registry_key",
        	"action": "create",
        	"recursive": true,
        	"values": [
        		{
        			"name": "key_name",
        			"type": "string",
        			"data": "value"
        		}
        	]
        }
      ]
    }
  }
}
```