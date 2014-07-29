#
# Cookbook Name:: shared_hosting
# Attributes:: apache_shared_ldap
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

default['shared_hosting']['apache_shared_ldap']['ldap_host'] = "corp.contoso.com"
default['shared_hosting']['apache_shared_ldap']['ldap_port'] = 636
default['shared_hosting']['apache_shared_ldap']['ldap_encryption'] = :simple_tls
default['shared_hosting']['apache_shared_ldap']['ldap_base'] = "DC=contoso,DC=com"
default['shared_hosting']['apache_shared_ldap']['chef_vault'] = "ad_credentials"
default['shared_hosting']['apache_shared_ldap']['chef_vault_item'] = "pbis_bind"
default['shared_hosting']['apache_shared_ldap']['ldap_group_dn'] = "CN=Domain Users,CN=Users,DC=contoso,DC=com"

default['shared_hosting']['apache_shared_ldap']['home_prefix'] = "/srv/home"
default['shared_hosting']['apache_shared_ldap']['server_name'] = "example.contoso.com"
default['shared_hosting']['apache_shared_ldap']['site_template'] = "apache2-shared-site.erb"
default['shared_hosting']['apache_shared_ldap']['ssl_site_template'] = "apache2-shared-site-ssl.erb"
default['shared_hosting']['apache_shared_ldap']['ssl_cert_file'] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
default['shared_hosting']['apache_shared_ldap']['ssl_cert_key']  = "/etc/ssl/private/ssl-cert-snakeoil.key"