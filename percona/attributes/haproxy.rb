#
# Cookbook Name:: percona
# Attributes:: loadbalance
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

# Default listener for MySQL connections (reads and writes)
default['percona']['haproxy_write_port'] = 3306
# Option to enable load-balanced MySQL listener for read-only use
default['percona']['haproxy_enable_readonly_listener'] = true
default['percona']['haproxy_read_port'] = 3307
# Option to enable HAProxy stats
default['percona']['haproxy_enable_stats'] = true
default['percona']['haproxy_stats_port'] = 8282
default['percona']['haproxy_stats_user'] = "stats"
default['percona']['haproxy_stats_password'] = "Passw0rd"