windows\_tasks Cookbook
======================
This cookbook leverages the windows\_task LWRP from Opscode's cookbook and allows you to manage Windows scheduled tasks via the nodes' attributes.

Requirements
------------
#### cookbooks
- `windows`

Usage
-----
#### windows\_tasks::default
Include `windows_tasks` in your node's `run_list`. Populate the node's \['windows'\]\['scheduled\_tasks'\] attribute with an array of hashes for each scheduled task to create/delete/modify. See the Opscode windows cookbook for an explanation of windows\_task LWRP and associated options.

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[windows_tasks]"
  ],
  "override_attributes": {
    "windows": {
      "scheduled_tasks": [
        {
          "Task name": {
            "user": "myusername",
            "password": "mypassword",
            "run_level": "highest",
            "cwd": "c:/bin",
            "command": "c:/bin/hug_kitens.bat",
            "frequency": "minute",
            "frequency_modifier": 15,
            "action": "create"
          }
        }
      ]
    }
  }
}
```

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

