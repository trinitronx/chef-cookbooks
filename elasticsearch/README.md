elasticsearch Cookbook
================
This cookbook is used to install and configure Elasticsearch on a single node or in a clustered configuration.

Requirements
------------
This cookbook has been tested on Ubuntu 12.04.

Attributes
----------

#### elasticsearch::default
* `node['elasticsearch']['install_version']` - the version of Elasticsearch to install
* `node['elasticsearch']['cluster_name']` - the name of the cluster
* `node['elasticsearch']['master_node']` - is the node a master in the cluster; defaults to true
* `node['elasticsearch']['http_port']` - the TCP port for HTTP requests
* `node['elasticsearch']['transport_port']` - the TCP port for node communication
* `node['elasticsearch']['limits_nofile']` - number of open files limit for the elasticsearch user
* `node['elasticsearch']['limits_memlock']` - memory lock limit for the elasticsearch user

Recipes
---------

#### elasticsearch::default
Installs and configures Elasticsearch. Also includes the java cookbook to install the Oracle Java JDK.

#### elasticsearch::repository
Sets up the Elasticsearch apt repository.

Usage
-----

Create a role that sets default attributes, such as the cluster name, and assign it to one or more nodes in Chef. If needed, update the Java attributes to install a different or newer JDK version. In a clustered configuration, the nodes can be brought up in any order, as Elasticsearch will function even if other master nodes cannot be reached.

License and Authors
-------------------
- Author:: Jared King <jared.king@biola.edu>

```text
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
```