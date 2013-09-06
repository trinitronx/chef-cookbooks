#
# Cookbook Name:: percona
# Attributes:: xtradb-cluster
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

default['percona']['xtradb_cluster_package'] = "percona-xtradb-cluster-server-5.5"
default['percona']['xtradb_cluster_client_packages'] = %w{percona-xtradb-cluster-client-5.5 libmysqlclient18-dev}
default['percona']['cluster_name'] = "percona_xtradb_cluster"
default['percona']['sst_method'] = "xtrabackup"
default['percona']['sst_user'] = "xtrabackup_user"
default['percona']['cluster_role'] = ""