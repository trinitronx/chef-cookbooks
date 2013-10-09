#
# Cookbook Name:: iptables-biola
# Attributes:: default_rules
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

# Set up default rules
default['iptables-ng']['rules']['filter']['FORWARD']['default'] = 'DROP [0:0]'
# Allow loopback traffic
default['iptables-ng']['rules']['filter']['INPUT']['01-loopback']['rule'] = '--in-interface lo --jump ACCEPT'
default['iptables-ng']['rules']['filter']['INPUT']['01-loopback']['ip_version'] = 4
# Allow ICMP
default['iptables-ng']['rules']['filter']['INPUT']['02-icmp']['rule'] = '--protocol icmp --icmp-type any --jump ACCEPT'
default['iptables-ng']['rules']['filter']['INPUT']['02-icmp']['ip_version'] = 4
# Allow established connections
default['iptables-ng']['rules']['filter']['INPUT']['03-established']['rule'] = '--match state --state ESTABLISHED,RELATED --jump ACCEPT'
default['iptables-ng']['rules']['filter']['INPUT']['03-established']['ip_version'] = 4
# Log blocked TCP traffic
default['iptables-ng']['rules']['filter']['INPUT']['zy-log_tcp']['rule'] = "--match limit --limit #{node['firewall']['log_limit']} --match tcp --protocol tcp --jump LOG --log-prefix \"Denied TCP: \" --log-level #{node['firewall']['log_level']}"
default['iptables-ng']['rules']['filter']['INPUT']['zy-log_tcp']['ip_version'] = 4
# Block traffic that doesn't match any other rules
default['iptables-ng']['rules']['filter']['INPUT']['zz-block_default']['rule'] = '--jump REJECT --reject-with icmp-host-prohibited'
default['iptables-ng']['rules']['filter']['INPUT']['zz-block_default']['ip_version'] = 4