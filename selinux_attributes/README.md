selinux_attributes Cookbook
===========================

This cookbook allows for SELinux enforcement policy via attributes. Will be retired when this support is added to Opscode's selinux cookbook.

Requirements
------------

#### cookbooks
- `selinux`

Attributes
----------

#### selinux_attributes::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['selinux']['state']</tt></td>
    <td>String</td>
    <td>SELinux enforcement state</td>
    <td><tt>nil</tt></td>
  </tr>
</table>

Usage
-----
#### selinux_attributes::default

Set the state attribute noted above, and include `selinux_attributes` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[selinux_attributes]"
  ]
}
```



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

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

