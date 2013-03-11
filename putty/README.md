putty Cookbook
==============
Simple cookbook for deploying PuTTY on windows

Requirements
------------

#### cookbooks
- `windows` - putty is deployed with as a Windows package.


Usage
-----
#### putty::default
Just include `putty` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[putty]"
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

