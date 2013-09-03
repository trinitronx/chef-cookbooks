#
# Cookbook Name:: percona
# Recipe:: repository
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

# Add the Percona repository and grab key from keyserver (do this during the compilation phase)
a = apt_repository "percona" do
  uri "http://repo.percona.com/apt"
  distribution node['lsb']['codename']
  components ["main"]
  keyserver "keys.gnupg.net"
  key "1C4CBDCDCD2EFD2A"
  deb_src true
  notifies :run, resources(:execute => "apt-get update"), :immediately
	not_if do
		File.exists?("/etc/apt/sources.list.d/percona.list")
  end
end
a.run_action(:add)