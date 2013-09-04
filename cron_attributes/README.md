cron_attributes Cookbook
========================

This cookbook processes cron.d entries on your nodes' attributes.

Requirements
------------

#### cookbooks
- `cron`

Attributes
----------

Most attributes are directly mapped to their equivalents in the cron_d lwrp; see its README for information on their usage & default values.

```json
{
  "name":"my_role",
  "default_attributes": {
    "cron": {
      "entries": [
        {
          "myfirstcronentry": {
            "minute": "*",
            "hour": "*",
            "day": "*",
            "month": "*",
            "weekday": "*",
            "command": "/bin/required command", #required
            "user": "root",
            "mailto": "",
            "path": "",
            "home": "",
            "shell": ""
            "action": "delete"  #optional; set to delete to remove the cronjob
          }
        },
        {
          "mysecondcronentry": {
            "minute": "0",
            "hour": "17",
            "day": "5",
            "month": "5",
            "command": "/bin/cinco_de_mayo"
          }
        }
      ]
    }
  }
}
```

Usage
-----
#### cron_attributes::default
Include `cron_attributes` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[cron_attributes]"
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

