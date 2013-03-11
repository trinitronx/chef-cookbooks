#
# Cookbook Name:: vsftpd
# Attributes:: vsftpd
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

# The path to the configuration file
default['vsftpd']['conf_file'] = "/etc/vsftpd.conf"
# Enable anonymous authentication
default['vsftpd']['anonymous_enable'] = "NO"
# Allow local users to log in
default['vsftpd']['local_enable'] = "YES"
# Allow users to perform any write command
default['vsftpd']['write_enable'] = "YES"
# Default umask for all uploaded files
default['vsftpd']['local_umask'] = "022"
# Path to the list of users allowed to use FTP
default['vsftpd']['userlist_file'] = "/etc/vsftpd.user_list"
# The group to pull a list of allowed users from
# The default recipe will search the "users" databag for any user that has the following group specified
default['vsftpd']['userlist_group'] = "netopsftp"