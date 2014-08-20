#
# Cookbook Name:: opsview
# Attributes:: check_mssql
#
# Copyright 2014, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE_2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['opsview']['check_mssql']['plugin_version'] = "1.5.19.3"
default['opsview']['check_mssql']['plugin_url'] = "http://labs.consol.de/download/shinken-nagios-plugins/check_mssql_health-1.5.19.3.tar.gz"
default['opsview']['check_mssql']['plugin_checksum'] = "5f310834952e38e8166248ef5c8798b4"
default['opsview']['check_mssql']['statefiles_dir'] = "/tmp/check_mssql_health"