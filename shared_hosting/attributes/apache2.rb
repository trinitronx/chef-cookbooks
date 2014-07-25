#
# Cookbook Name:: shared_hosting
# Attributes:: apache2
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

default['shared_hosting']['apache2']['sites_dir'] = "/srv/www"

default['shared_hosting']['apache2']['ssl_cert_file'] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
default['shared_hosting']['apache2']['ssl_cert_key']  = "/etc/ssl/private/ssl-cert-snakeoil.key"