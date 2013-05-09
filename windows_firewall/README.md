windows\_firewall Cookbook
=========================
This cookbook emulates the style of the ufw cookbook to provide a simple way to manage firewall exceptions on Windows nodes via attributes.

Requirements
------------
Windows >= 2008/Vista

Attributes
----------

Same as the firewall/ufw cookbook attributes. The 'profile' value has been added to the firewall rules to optionally allow the Windows network profile to be specified (defaults to domain).

Usage
-----
#### windows\_firewall::default
Include `windows_firewall` in your node's `run_list` along with the proper attributes:

```json
{
  "name":"my_node",
  "default_attributes": {
    "firewall": {
      "rules": [
        {
          "My First Port": {
            "port": "7200",
            "profile": "domain"
          }
        },
        {
          "My Second Port": {
            "port": "7201"
          }
        }
      ]
    }
  },
  "run_list": [
    "recipe[windows_firewall]"
  ]
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
 Copyright 2011, Opscode, Inc

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

