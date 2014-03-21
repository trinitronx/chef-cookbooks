opsview Cookbook
================
This cookbook installs and configures Opsview Core on a Ubuntu server. It also handles the installation and configuration of the Opsview agent on Windows and Linux clients.

Requirements
------------

#### client.rb
Tested on CentOS, RHEL, Ubuntu, and Windows Server 2003+.

#### core.rb
Tested on Ubuntu 12.04.

Attributes
----------

#### opsview::client
* `node['opsview']['agent_conf_dir']` - where to put the agent configuration files
* `node['opsview']['windows_agent_x64_url']` - location of the Opsview Agent package for 64-bit Windows systems
* `node['opsview']['windows_agent_Win32_url']` - location of the Opsview Agent package for 32-bit Windows systems

#### opsview::default
* `node['opsview']['server_role']` - the name of the server role for the Opsview server; used by clients to search for IP addresses to allow connections from
* `node['opsview']['plugin_dir']` - the directory Opsview plugins are stored in (Linux only)

#### opsview::core
* `node['opsview']['nagios_user_home']` - the home directory for the nagios user
* `node['opsview']['conf_dir']` - the directory Opsview stores it's configuration in
* `node['opsview']['json_config_dir']` - the directory to store local JSON configuration before pushing to Opsview
* `node['opsview']['icons_dir']` - where to store custom icons
* `node['opsview']['opsview_rest_path']` - the location of the `opsview_rest` binary
* `node['opsview']['extra_packages']` - extra packages to install with Opsview Core
* `node['opsview']['default_keywords']` - keywords to attach to hosts and service checks by default
* `node['opsview']['use_ssl']` - whether to enable SSL for the Opsview web interface
* `node['opsview']['ssl_certificate_file']` - location of the SSL certificate
* `node['opsview']['ssl_certificate_keyfile']` - location of the matching private key

Recipes
---------

#### opsview::default
Includes the `opsview::client` recipe to install the Opsview agent.

#### opsview::apt_repository
Sets up Opsview's apt repository on Ubuntu systems; called from the `opsview::client` and `opsview::core` recipes before installation.

#### opsview::core
Installs and configures Opsview Core on a system. The recipe does the following:

1. Installs MySQL using the `mysql::server` recipe
2. Retrieves the MySQL root password and pre-seeds the Opsview Core installation
3. Installs the opsview package from Opsview's apt repository
4. Sets up Apache, optionally with SSL
5. Updates the password for the admin account
6. Installs custom icons, plugins, and event handlers
7. Searches for nodes in the Chef environments specified
8. Pulls configuration from data bags
9. For each object type (host, service check, etc), does the following:
    1. Checks for objects that no longer exist in Chef and deletes them from Opsview
    2. Creates a JSON file that includes all of the objects and their configuration
    3. Pushes the JSON to Opsview using the REST API if the configuration has changed
10. Reloads the Opsview running configuration if changes have been made

#### opsview::knife
Configures Chef client config to allow the Opsview server to perform knife commands.

#### opsview::ldap
Configures LDAP authentication for the Opsview server.

#### opsview::pagerduty
Adds configuration to Opsview to send notifications to PagerDuty.

#### opsview::vmware
Installs the VMware Perl API and other dependencies needed for vCenter service checks.

#### opsview::yum_repository
Sets up Opsview's yum repository on CentOS and RHEL systems; called from the `opsview::client` recipe before installation.

Data Bags
---------

#### opsview_attributes
Contains custom attributes for storing credentials and other information with a host. The arguments (arg1-4) are optional and can be used instead of the value field to store more than one value (both a username and password for instance).

```json
{
  "name": "MYSQLCREDENTIALS",
  "value": "Enter credentials here",
  "arg1": "username",
  "arg2": "password",
  "arg3": "",
  "arg4": ""
}
```

#### opsview_contacts
Stores contact information to add to Opsview. The password for the admin account can be changed by adding an item to this data bag. Encrypted passwords can be obtained by running `openssl passwd -apr1 'passwordhere'`.

```json
{
  "name": "john",
  "fullname": "John Doe",
  "encrypted_password": "",
  "role": "Administrator",
  "keywords": [  "keyword1" ]
  "email": "john@email.com"
  "sharednotificationprofiles": [ "shared_profile1" ],
  "variables": [
    {
      "name": "variable1",
      "value": "valuegoeshere"
    }
  ]
}
```

#### opsview_hostgroups
Used for logical grouping of monitored hosts.

```json
{
  "name": "Development",
  "matpath": "Opsview,Development,"
}
```

#### opsview_hosttemplates
Used to store host templates. Service checks should be added to host templates rather than individual hosts.

```json
{
  "name": "OS - Unix Base",
  "description": "Common Unix agent monitors"
}
```

#### opsview_keywords
Stores keywords for tagging hosts and services. By default the PagerDuty contact is notified for hosts and services with the "pagerduty" keyword.

```json
{
  "name": "netops",
  "description": "Hosts and services managed by the Network Operations team"
}
```

#### opsview_servicechecks
Contains service check definitions.

```json
{
  "name": "Unix Load Average",
  "description": "Checks Load Average",
  "args": "-H $HOSTADDRESS$ -c check_load -a '-w 5,5,5 -c 9,9,9'",
  "dependencies": [ "Opsview Agent" ],
  "event_handler": "custom_event_handler",
  "hosts": [ "myhost.domain.com" ],
  "hosttemplates": [ "OS - Unix Base" ],
  "keywords": [ "unix" ],
  "plugin": "check_nrpe", 
  "servicegroup": "OS - Base Unix Agent"
}
```

#### opsview_servicegroups
Used to logically group services together.

```json
{
  "name": "OS - Base Unix Agent"
}
```

#### opsview_sharednotificationprofiles
Stores shared notification profiles to be used by different contacts.

```json
{
  "name" : "pagerduty-shared",
  "fullname" : "PagerDuty",
  "keywords": [ "pagerduty" ],
  "notificationmethods": [ "pagerduty" ],
  "role": "View some, change none"
}
```

#### opsview_timeperiods
Contains custom timeperiods to add to Opsview.

```json
{
  "name" : "24x7",
  "alias" : "24 Hours A Day, 7 Days A Week",
  "sunday": "00:00-24:00",
  "monday": "00:00-24:00",
  "tuesday": "00:00-24:00",
  "wednesday": "00:00-24:00",
  "thursday": "00:00-24:00",
  "friday": "00:00-24:00",
  "saturday": "00:00-24:00"
}
```

#### opsview_unmanagedhosts
Stores configuration for hosts that are not managed with Chef.

```json
{
  "name" : "myhost1",
  "hostgroup" : "Development",
  "hostattributes": [
    {
      "name": "MYSQLCREDENTIALS",
      "value": "notusedbutrequired",
      "arg1": "usernamegoeshere",
      "arg2": "passwordgoeshere"
    }
  ],
  "hosttemplates": [ "OS - Linux SNMP", "Database - MySQL Server" ],
  "platform": "ubuntu",
  "keywords": [ "mysql" ],
  "notification_period": "business_hours",
  "snmp_community": "public",
  "exceptions": [
    {
      "name": "MySQL DB Listener",
      "exception": "-H $HOSTADDRESS$ -p 3307 -w 2 -c 5"
    }
  ]
}
```

Usage
-----
#### opsview::default
Create roles for nodes to use that define a host group and host template, and include the `opsview` recipe in the `run_list` to install and configure the Opsview agent. Once the attributes have been added to the node, the Opsview server will add it as a monitored host on the next chef-client run.

```json
{
  "default_attributes": {
    "opsview": {
      "hostgroup": "Development",
      "hosttemplates": [
        "OS - Unix Base"
      ]
    }
  },
  "run_list": [
    "recipe[opsview]"
  ]
}
```

##### Optional attributes
Other host attributes can be configured using optional attributes. For example, to add an exception for a service check use the `exceptions` attribute to specify the name of the service check and the arguments to use instead of the default.

```json
{
  "default_attributes": {
    "opsview": {
      "hostattributes": [
        {
          "name": "MYSQLCREDENTIALS",
          "value": "notusedbutrequired",
          "arg1": "usernamegoeshere",
          "arg2": "passwordgoeshere"
        }
      ],
      "keywords": [ "mysql" ],
      "notification_period": "business_hours",
      "exceptions": [
        {
          "name": "MySQL DB Listener",
          "exception": "-H $HOSTADDRESS$ -p 3307 -w 2 -c 5"
        }
      ]
    }
  }
}
```

##### Adding a custom command to the Opsview Agent for Linux
To add a command for a custom plugin to the node's configuration, add the following attributes to the node. The plugin_dir attribute can be included if the plugin is located outside of the default directory.

```json
{
  "default_attributes": {
    "opsview": {
      "commands": {
        "check_load": {
          "name": "check_load",
          "plugin": "check_load",
          "plugin_dir": "/usr/local/nagios/libexec"
        }
      }
    }
  }
}
```

##### Adding a custom alias/script to the Opsview Agent for Windows
To add a custom script or alias to the node's configuration, add the following attributes to the node. Any custom scripts must be contained in the "scripts" subdirectory.

```json
{
  "default_attributes": {
    "opsview": {
      "aliases": [
        {
          "name": "nsc_checkmem",
          "module": "CheckMem"
        }
      ],
      "scripts": [
        {
          "name": "restart_chefclient",
          "filename": "restart_service.bat",
          "arguments": "chef-client"
        }
      ]
    }
  }
}
```

#### opsview::core

Create a role for the Opsview server to use (default is `opsview_host`) and add the `opsview::core` recipe to the run list along with any attributes that need to be changed from the defaults. Create data bags for any custom objects that need to be added to Opsview Core or to modify existing built-in objects. On the next chef-client run MySQL and Opsview Core will be installed and any objects in data bags will be added to the running configuration.

#### opsview::ldap

If LDAP authentication will be used with Opsview, include the `opsview::ldap` recipe in the role used by the Opsview server along with the required attributes below.

```json
{
  "default_attributes": {
    "opsview": {
      "ldap": {
        "groups": [
          "Opsview_Admins"
        ],
        "group_basedn": "ou=Groups,dc=domain,dc=com",
        "ldap_server": "ldap.domain.com",
        "user_basedn": "ou=Users,dc=domain,dc=com",
        "user_filter": "(&(sAMAccountName=%s)(memberOf=cn=Opsview_Admins,ou=Groups,dc=domain,dc=com))"
      }
    }
  }
}
```

The recipe also uses the chef_vault cookbook to retrieve encrypted authentication information. Create a vault item in the following format and give access to the Opsview server node:

```json
{
  "id": "opsview_auth",
  "ldap_bind_dn": "opsview_auth",
  "ldap_password": "passwordgoeshere"
}
```

#### opsview::pagerduty

To use PagerDuty with Opsview, include the `opsview::pagerduty` recipe in the role used by the Opsview server along with the API key for the PagerDuty service. By default all hosts and services defined by this cookbook will have the `pagerduty` keyword attached, and will be configured to send notifications to PagerDuty.

```json
{
  "default_attributes": {
    "opsview": {
      "pagerduty_key": "keyfrompagerdutygoeshere"
    }
  }
}
```

License and Authors
-------------------
- Author:: Jared King <jared.king@biola.edu>

```text
Copyright 2014, Biola University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```