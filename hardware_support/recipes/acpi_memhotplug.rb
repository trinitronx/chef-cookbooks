#
# Cookbook Name:: hardware_support
# Recipe:: acpi_memhotplug
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

# Virtualized nodes should load this module, if it exists and
# isn't already loaded
unless node['virtualization'].nil? 
  if node['virtualization']['role'] == "guest"
    execute "modprobe acpi_memhotplug" do
      not_if "cat /proc/modules | grep -i acpi_memhotplug"
      only_if "test -f /lib/modules/$(uname -r)/kernel/drivers/acpi/acpi_memhotplug.ko"
    end
  end
end
