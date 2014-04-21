#
# Cookbook Name:: opsview
# Attributes:: core
#
# Copyright 2013, Biola University
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

default['opsview']['nagios_user_home'] = "/var/lib/nagios"
default['opsview']['conf_dir'] = "/usr/local/nagios/etc"
default['opsview']['json_config_dir'] = "#{node['opsview']['nagios_user_home']}/json_config"
default['opsview']['icons_dir'] = "#{node['opsview']['nagios_user_home']}/icons"
default['opsview']['opsview_rest_path'] = "/usr/local/nagios/bin/opsview_rest"
default['opsview']['extra_packages'] = %w{ imagemagick }
default['opsview']['default_keywords'] = [ "pagerduty" ]

default['opsview']['use_ssl'] = false
default['opsview']['ssl_certificate_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
default['opsview']['ssl_certificate_keyfile'] = '/etc/ssl/private/ssl-cert-snakeoil.key'

default['opsview']['attributes_databag'] = "opsview_attributes"
default['opsview']['contacts_databag'] = "opsview_contacts"
default['opsview']['hostgroups_databag'] = "opsview_hostgroups"
default['opsview']['hosttemplates_databag'] = "opsview_hosttemplates"
default['opsview']['keywords_databag'] = "opsview_keywords"
default['opsview']['roles_databag'] = "opsview_roles"
default['opsview']['servicechecks_databag'] = "opsview_servicechecks"
default['opsview']['servicegroups_databag'] = "opsview_servicegroups"
default['opsview']['sharednotificationprofiles_databag'] = "opsview_sharednotificationprofiles"
default['opsview']['timeperiods_databag'] = "opsview_timeperiods"
default['opsview']['unmanagedhosts_databag'] = "opsview_unmanagedhosts"