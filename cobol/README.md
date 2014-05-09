cobol Cookbook
==============

This cookbook was designed to support the basic installation and configuration of Micro Focus COBOL on RHEL.

Requirements
------------

Tested on RHEL 5

Attributes
----------

#### cobol::microfocus
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cobol']['microfocus']['download_url']</tt></td>
    <td>String</td>
    <td>URL for your MF COBOL package</td>
    <td><tt>replaceme</tt></td>
  </tr>
  <tr>
    <td><tt>['cobol']['microfocus']['download_checksum']</tt></td>
    <td>String</td>
    <td>SHA256sum MF COBOL package</td>
    <td><tt>replaceme</tt></td>
  </tr>
  <tr>
    <td><tt>['cobol']['microfocus']['express_serial_number']</tt></td>
    <td>String</td>
    <td>Serial number for your Server Express product</td>
    <td><tt>replaceme</tt></td>
  </tr>
  <tr>
    <td><tt>['cobol']['microfocus']['express_license_key']</tt></td>
    <td>String</td>
    <td>License number for your Server Express product</td>
    <td><tt>replaceme</tt></td>
  </tr>
  <tr>
    <td><tt>['cobol']['microfocus']['user_serial_number']</tt></td>
    <td>String</td>
    <td>Serial number for your app/user licensing</td>
    <td><tt>replaceme</tt></td>
  </tr>
  <tr>
    <td><tt>['cobol']['microfocus']['user_license_key']</tt></td>
    <td>String</td>
    <td>License number for your app/user licensing</td>
    <td><tt>replaceme</tt></td>
  </tr>
  <tr>
    <td><tt>['cobol']['microfocus']['default_system_mode']</tt></td>
    <td>String</td>
    <td>Default COBMODE - should be either 32 or 64</td>
    <td><tt>64</tt></td>
  </tr>
</table>

Usage
-----
#### cobol::microfocus

# Retrieve the sx51_ws8_redhat_x86_64_dev.tar file from your installation DVD
# Gzip the file
# Note the sha256 checksum of the produced file 
# Move the archive to your http/ftp server
# Update the attributes listed above with appropriate values for your system(s)
# Include `cobol::microfocus` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[cobol]"
  ]
}
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

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
