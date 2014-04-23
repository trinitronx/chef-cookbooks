#
# Cookbook Name:: iptables-biola
# Recipe:: default
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

# Check to see if the firewall rules have changed
old_state = node['firewall']['state']
new_state = node['firewall']['rules'].to_s

if old_state == new_state
  Chef::Log.info "Firewall rules unchanged."
else
  Chef::Log.info "Firewall rules updated."
  node.set['firewall']['state'] = new_state

  # Empty the /etc/iptables.d directory
  directory '/etc/iptables.d' do
    recursive true
    action :delete
  end
  directory '/etc/iptables.d' do
    mode 00700
  end

  # Create the default firewall rules from attributes
  include_recipe "iptables-ng::default"

  # Parse each of the firewall rule attributes
  node['firewall']['rules'].each_with_index do |parameters, index|
    parameters.each_key do |rule_name|
      # Create the contents of the rule using the attributes given
      firewall_protocol = parameters[rule_name].attribute?('protocol') ? parameters[rule_name]['protocol'] : node['firewall']['default_protocol']
      firewall_action = parameters[rule_name].attribute?('action') ? parameters[rule_name]['action'].downcase : node['firewall']['default_action']
      firewall_actions = { 'allow' => 'ACCEPT', 'deny' => 'DROP', 'redirect' => 'REDIRECT', 'reject' => 'REJECT' }

      if parameters[rule_name].attribute?('static_rule')
        firewall_rule = parameters[rule_name]['static_rule']
      else
        firewall_rule = String.new
        firewall_rule << "--match state --state NEW " if (parameters[rule_name].attribute?('port') && firewall_action == 'allow')
        firewall_rule << "--match #{firewall_protocol} --protocol #{firewall_protocol} " if parameters[rule_name].attribute?('port')
        firewall_rule << "--source #{parameters[rule_name]['source']} " if parameters[rule_name]['source']
        firewall_rule << "--source-port #{parameters[rule_name]['src_port']} " if parameters[rule_name]['src_port']
        firewall_rule << "--destination #{parameters[rule_name]['destination']} " if parameters[rule_name]['destination']
        firewall_rule << "--dport #{parameters[rule_name]['port']} " if parameters[rule_name].attribute?('port')
        firewall_rule << "--jump #{firewall_actions[firewall_action]} "
        firewall_rule << "#{parameters[rule_name]['parameters']} " if parameters[rule_name]['parameters']
      end

      # Create the rule using the iptables_ng_rule LWRP
      iptables_ng_rule rule_name.to_s.downcase.tr(" ", "_") do
        chain parameters[rule_name]['chain'] if parameters[rule_name]['chain']
        table parameters[rule_name]['table'] if parameters[rule_name]['table']
        ip_version 4
        rule firewall_rule
      end
    end
  end
end