#
# Cookbook Name:: shared_hosting
# Attributes:: wordpress
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

default['shared_hosting']['wordpress']['php_packages'] = %w{ php5-curl php5-gd php5-mcrypt }
default['shared_hosting']['wordpress']['sites_dir'] = "/srv/nginx"
default['shared_hosting']['wordpress']['socket_dir'] = "/var/run/php5-fpm"
default['shared_hosting']['wordpress']['chroot_group'] = "sftp"

# SSL options
default['shared_hosting']['wordpress']['ssl_cert_file'] = "#{node['nginx']['dir']}/certs/selfsigned.crt"
default['shared_hosting']['wordpress']['ssl_cert_key']  = "#{node['nginx']['dir']}/certs/selfsigned.key"
default['shared_hosting']['wordpress']['ssl_req'] = "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node.name}/emailAddress=ops@#{node.name}"