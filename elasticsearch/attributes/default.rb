#
# Cookbook Name:: elasticsearch
# Attributes:: default
#
# Copyright 2014, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['elasticsearch']['install_version'] = "1.1"
default['elasticsearch']['cluster_name'] = 'elasticsearch'
default['elasticsearch']['master_node'] = true
default['elasticsearch']['http_port'] = '9200'
default['elasticsearch']['transport_port'] = '9300'

default['elasticsearch']['limits_nofile'] = '64000'
default['elasticsearch']['limits_memlock'] = 'unlimited'

# Java options
override['java']['install_flavor'] = 'oracle'
override['java']['jdk_version'] = '7'
override['java']['oracle']['accept_oracle_download_terms'] = true
override['java']['jdk']['7']['x86_64']['url'] = 'http://download.oracle.com/otn-pub/java/jdk/7u55-b13/jdk-7u55-linux-x64.tar.gz'
override['java']['jdk']['7']['x86_64']['checksum'] = '9e1fb7936f0e5aaa1e64d36ba640bc1f'