usersandgroups Cookbook
=======================

This cookbook extends the official Chef users cookbook and adds the ability o manage users and groups via attributes.

Requirements
------------

- The users cookbook


Usage
-----
#### usersandgroups::default

Include `usersandgroups` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[usersandgroups]"
  ]
}
```

Users and groups can now be defined in the following format:

node
  'usersandgroups'
    'users':[
      {
      exampleusername: {
        delete_user = false (if set to true, the user account will only be deleted)
        ignore_databag = false (if true, won't attempt to pull records from the users databag
        create_if_missing = false (by default a users password 
        disable_manage_home = false (if true, manage_home user attribute will not be set)
        uid = optional, system group without it. Can be set in users data_bag
        gid = optional. Can be set in users data_bag
        shell = optional. Can be set in users data_bag
        password = optional. Can be set in users data_bag
        comment = optional (aka the user's full name). Can be set in users data_bag
        }
      }
    'groups':[
      {
      'examplegroup':{
        gid = optional when creating a system group
        create_only = false (uses the users cookbook lwrp, if true just uses the group resource)
        environment = optional. When set, the group will only be acted upon in that environment
        group_name = optional. Allows a different group to be searched for in the databag than the name of the group on the node.
        }
      }

#### usersandgroups::userapps

Include this in your node's runlist to install general purpose apps used by users (e.g. screen).

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Copyright 2013, Biola University
Copyright 2011, Eric G. Wolfe
Copyright 2009-2011, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


