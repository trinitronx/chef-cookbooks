#
# Cookbook Name:: opsview
# Attributes:: ldap
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

default['opsview']['ldap']['vault'] = "ad_credentials"
default['opsview']['ldap']['vault_item'] = "opsview_bind"

default['opsview']['ldap']['ldap_server'] = "ldap.company.com"
default['opsview']['ldap']['start_tls'] = "1"
default['opsview']['ldap']['tls_cafile'] = "/etc/ssl/certs/ca-certificates.crt"
default['opsview']['ldap']['user_basedn'] = "cn=Users,dc=ldap,dc=company,dc=com"
default['opsview']['ldap']['user_filter'] = "(sAMAccountName=%s)"
default['opsview']['ldap']['user_scope'] = "sub"
default['opsview']['ldap']['group_dir'] = "/usr/local/nagios/etc/ldap"
default['opsview']['ldap']['group_basedn'] = "cn=Users,dc=ldap,dc=company,dc=com"
default['opsview']['ldap']['group_filter'] = "(&(objectClass=group)(sAMAccountName=%s))"
default['opsview']['ldap']['group_scope'] = "sub"

default['opsview']['ldap']['default_role'] = "Public"
default['opsview']['ldap']['default_allhostgroups'] = "0"
default['opsview']['ldap']['default_allservicegroups'] = "0"