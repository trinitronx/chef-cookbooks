#
# Cookbook Name:: opsview
# Attributes:: oracle
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

default['opsview']['oracle']['dbd_oracle_version'] = "1.74"
default['opsview']['oracle']['dbd_oracle_url'] = "http://search.cpan.org/CPAN/authors/id/P/PY/PYTHIAN/DBD-Oracle-1.74.tar.gz"
default['opsview']['oracle']['dbd_oracle_checksum'] = "b89d40036bf98cbc665ed3c6b1436323"

default['opsview']['oracle']['plugin_version'] = "1.9.3.4"
default['opsview']['oracle']['plugin_url'] = "http://labs.consol.de/download/shinken-nagios-plugins/check_oracle_health-1.9.3.4.tar.gz"
default['opsview']['oracle']['plugin_checksum'] = "12bbe9aaa71ea05b4d400186839ecdd4"