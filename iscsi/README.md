iscsi Cookbook
==============
Configures iscsi. Currently focused on iscsi target configuration on Ubuntu.

Requirements
------------

Ubuntu 12.04+

Attributes
----------
#### iscsi::target

Standard iscsi-target values should be populated as follows. Initiator, username, & password are optional (if specifying user/pass, make sure to use a 12 character password per RFC).

The initiator string is passed directly to the initiators.allow file, so it can contain mulitiple initiators/subnets/etc. If it is not specified, defaults to ALL.

```json
{
  "default_attributes": {
    "iscsi": {
      "targets": [
        {
          "iqn.2004-03.com.dm:salesreports": {
            "path": "/volumes/dunderm.img",
            "lun": "0",
            "iotype": "fileio",
            "initiator": "192.168.0.20",
            "username": "chapuserjim",
            "password": "pamlovescake"
          }
        },
        {
          "iqn.2004-03.com.dm:partyplanning": {
            "path": "/dev/zvol/zpool1/committee",
            "lun": "0",
            "iotype": "blockio"
          }
        }
      ]
    }
  }
}
```

Usage
-----
#### iscsi::target
Sets up and configures iscsi targets on your Ubuntu server. See attribute usage above.

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add\_component\_x`)
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

