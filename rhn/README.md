rhn Cookbook
============
This cookbook registers RHEL systems to RHN. Currently using the rhnreg\_ks tool

TODO: Add support for subscription-manager & activation keys

Requirements
------------

#### distro
- Tested on RHEL 5/6

Attributes
----------

#### rhn::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['rhn']['username']</tt></td>
    <td>string</td>
    <td>RHN username for registering nodes</td>
    <td><tt>username</tt></td>
  </tr>
  <tr>
    <td><tt>['rhn']['password']</tt></td>
    <td>string</td>
    <td>RHN user's password</td>
    <td><tt>password</tt></td>
  </tr>
</table>

#### rhn::optionalchannel
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['rhn']['operating_system']</tt></td>
    <td>string</td>
    <td>Operating system type for optional channel registration; should be workstation, client or server</td>
    <td><tt>server</tt></td>
  </tr>
</table>

Usage
-----
#### rhn::default

* Set the username & password attributes specified above
* Include `rhn` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[rhn]"
  ]
}
```

#### rhn::optionalchannel

Include this recipe in a node's run_list to have it add the Optional channel on RHN.



License and Authors
-------------------
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

