#
# Cookbook Name:: users
# Recipe:: formeremployeestodelete
#
# Copyright 2012, Biola University
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


# search for users with a group membership of 'formeremployeestodelete' in the 'users' data bag and loop over them
search(:users, "groups:formeremployeestodelete") do |userstodelete|
  # Set `login` to the id of the data bag item
  login = userstodelete["id"]
 
  # for each matched user, delete them
  user(login) do
    action :remove
  end
 
end
