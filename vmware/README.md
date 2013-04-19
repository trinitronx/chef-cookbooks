vmware Cookbook
===============
General tools and support installs

perlsdk
=======

Installs the [Perl SDK.](http://www.vmware.com/support/developer/viperltoolkit/)

Prepartion steps:
- Download the installer 
- Uncompress the installer
- Demonstrate your acceptance of its EULA by removing the requirement to accept it from the installer (see http://communities.vmware.com/message/714914?tstart=0 for info.

Should be as simple as changing:

```
 $gOption{'default'} = 0;
 show_EULA();
```

to

```
 $gOption{'default'} = 1;
 #show_EULA();
```
in the install file.

- Recompress the install package
- Place on a web/ftp server
- Define the ['vmware']['perlsdk_x64_url'] & ['vmware']['perlsdk_x64_checksum'] attributes on your node to point to the install file
- Apply the perlsdk recipe to the node

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

