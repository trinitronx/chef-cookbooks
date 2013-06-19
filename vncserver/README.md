vncserver Cookbook
==================
This cookbook configures systems to serve desktops via VNC.

Requirements
------------

#### distros
- Currently supports RHEL & derivatives

Attributes
----------
#### vncserver::autostart

Add attributes in the following manner on your node (this will populate the /etc/sysconfig/vncservers file):

```json
  "vncserver": {
      "users": [
        {
          "firstusernamehere": {
            "display": "1",
            "arguments": "-geometry 1024x768 -localhost"
          }
        },
        {
          "secondusername here": {
            "display": "2",
            "arguments": "-geometry 1024x768 -localhost"
          }
        }
      ]
    }
```

Usage
-----
#### vncserver::default
Just include `vncserver` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[vncserver]"
  ]
}
```

#### vncserver::autostart
* Update your node's attributes as detailed above
* Include `vncserver::autostart` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[vncserver]",
    "recipe[vncserver::autostart]"
  ]
}
```


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

