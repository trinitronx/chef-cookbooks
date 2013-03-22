#
# Cookbook Name:: nexenta
# Recipe:: dataon_dsm_plugin
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

apt_repository "dataonstorage" do
  uri node['nexenta']['dataon']['repouri']
  distribution node['nexenta']['dataon']['distribution']
  components node['nexenta']['dataon']['repocomponents']
  key node['nexenta']['dataon']['repokey']
  deb_src node['nexenta']['dataon']['includesourcerepo']
end
