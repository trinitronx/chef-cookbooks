netatalk_biola Cookbook
=======================

Installs and configures netatalk.

Current caveats:
* Targeting Ubuntu 12.04 installations only
* Deploys the latest version (3.1) of netatalk from source for Spotlight support
* Configuration file support is missing. Future revisions will target automatic afp.conf configuration via attributes
* Dconf settings should also be controlled by the recipe

Requirements
------------

#### platforms
- `ubuntu 12.04`

#### cookbooks
- `apt`


Usage
-----
#### netatalk_biola::default
Include `netatalk_biola` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[netatalk_biola]"
  ]
}
```

1. After install, netatalk will be installed but not started. Root's profile should be configured to interact with Tracker.
2. Configure shares and settings in /etc/afp.conf
3. Start the netatalk service

Optionally, you may wish to disable the on the fly Tracker scanning for your shares:
1. Disable spotlight tracking for each of your shares, then start the netatalk service.
2. Execute the following as root (not sudo):
- gsettings set org.freedesktop.Tracker.Miner.Files enable-monitors false
- gsettings set org.freedesktop.Tracker.Miner.Files crawling-interval 3

Optionally, verify the above settings with 'gsettings list-recursively | grep Tracker'

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
 
