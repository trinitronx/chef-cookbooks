#
# Cookbook Name:: shared_hosting
# Attributes:: change_password
#
# Copyright 2013, Biola University
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

default['shared_hosting']['change_password']['script_path'] = "/usr/local/bin"
# Dummy user for changing passwords via SSH
default['shared_hosting']['change_password']['dummy_user'] = "passwd"
# Default is 'passwd'
default['shared_hosting']['change_password']['dummy_password'] = "$6$n/Nr4nfwkx51$uNXz6J5/2mJGyUDzSIzwnxsK1FLlPN51QU825OvjIyEmagr1xBz9/FOIS8aQl7Si5oRgRex4pBjYc.7CdPsyQ/"