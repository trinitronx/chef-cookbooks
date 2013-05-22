sudoers Cookbook
======================
This cookbook leverages the sudo LWRP from Opscode's cookbook and allows you to create sudoers-fragments using the nodes' attributes.

Requirements
------------
#### cookbooks
- `sudo`

Usage
-----
#### sudoers::default
Include `sudoers` in your node's `run_list`. Populate the node's \['authorization'\]\['sudoers'\] attribute with an array of hashes for each sudoers-fragment to create. See the Opscode sudo cookbook for an explanation of the sudo LWRP and associated options.

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

