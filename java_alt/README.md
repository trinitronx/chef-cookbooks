java_alt Cookbook
=================

Provides the ability to install a second ('alt') Java JDK with the `java` cookbook.

Requirements
------------

The [java cookbook.](https://github.com/socrata-cookbooks/java)


Usage
-----
#### java_alt::default
Include `java_alt` in your node's `run_list`, and specify attributes like the following on your node/role to configure the install:

```json
{
  "java_alt": {
    "install_flavor": "oracle", # or openjdk, etc
    "jdk_version": "7", # or 6, etc
    "jdk": {
      "7": { # or 6, etc
        "x86_64": {
          "url": "YOUR_DOWNLOAD_URL",
          "checksum": "MD5 or SHA256 checksum"
        },
        "i586": {
          "url": "YOUR_DOWNLOAD_URL",
          "checksum": "MD5 or SHA256 checksum"
        }
      }
    }
  }
}
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
 Copyright 2014, Biola University 

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

