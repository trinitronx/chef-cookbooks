linux_scripts Cookbook
======================

Simply deploys generic scripts to linux systems. Will copy scripts to /usr/local/bin or sbin as appropriate.


Usage
-----
#### linux_scripts::default

Just include `linux_scripts` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[linux_scripts]"
  ]
}
```

#### linux_scripts::remote_scripts

Allows scripts stored on your own web/ftp server to be deployed via attributes specified on your node/roles.

e.g.:
```json
{
  "name":"my_role",
  "default_attributes": {
    "remote_scripts": [
      {
        "script1name": {
          "source": "http://mywebserver/myfile.erb",
          "path": "/usr/local/bin/myscriptname",
          "mode": "0555" #optional
        }
      }
    ]
  }
}
```

Just add additional hashes to the 'remote_scripts' array for each script to be deployed.


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

