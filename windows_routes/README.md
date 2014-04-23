windows\_routes Cookbook
=========================
This cookbook emulates the style of the ufw cookbook to provide a simple way to manage IP routes on Windows nodes via attributes.

Requirements
------------
Windows >= 2008/Vista

Usage
-----
#### windows\_routes::default
Include `windows_route` in your node's `run_list` along with the proper attributes:

```json
{
  "name":"my_node",
  "default_attributes": {
    "windows": {
      "routing": {
        "staticroutes": [
          {
            "192.168.40.0": {
              "mask": "255.255.255.0",
              "gateway": "192.168.1.1",
              "metric": "1"
            }
          },
          {
            "192.168.50.0": {
              "mask": "255.255.255.0",
              "gateway": "192.168.1.1",
              "metric": "10",
              "temporary": true
            }
          }
        ]
      }
    }
  },
  "run_list": [
    "recipe[windows_routes]"
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
Copyright 2014, Biola University 
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
