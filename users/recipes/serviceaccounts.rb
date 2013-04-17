#
# Cookbook Name:: users
# Recipe:: serviceaccounts
#
# Copyright 2013, Biola University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Look for users in the ['users']['serviceaccounts'] array
# in the form of "local_username:username_in_databag"
# and update their password

node['users']['serviceaccounts'].each do |serviceusername|
  user serviceusername.split(':')[0] do
    action :manage
    password data_bag_item('users', serviceusername.split(':')[1])['password']
  end
end
