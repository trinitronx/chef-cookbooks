iptables-biola Cookbook
=======================
This cookbook uses the attribute scheme from Opscode's ufw and firewall cookbooks and leverages the LWRP from the iptables-ng cookbook to manage iptables and create firewall rules.

Requirements
------------
This cookbook should be compatible with any platform supported by the iptables-ng cookbook.

Attributes
----------

#### iptables-biola::default_rules
This attributes file contains default rules for iptables, which are defined using the attribute definitions in the iptables-ng cookbook.

#### iptables-biola::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['firewall']['log_level']</tt></td>
    <td>Integer</td>
    <td>Value for iptables "--log_level" parameter</td>
    <td>7</td>
  </tr>
  <tr>
    <td><tt>['firewall']['log_limit']</tt></td>
    <td>String</td>
    <td>Value for iptables "--log_limit" parameter</td>
    <td>4/min</td>
  </tr>
  <tr>
    <td><tt>['firewall']['default_protocol']</tt></td>
    <td>String</td>
    <td>Default protocol to use when defining a firewall rule</td>
    <td>tcp</td>
  </tr>
  <tr>
    <td><tt>['firewall']['default_action']</tt></td>
    <td>String</td>
    <td>Default action to use when defining a firewall rule</td>
    <td>allow</td>
  </tr>
</table>

#### Firewall rule attributes
Firewall rules are defined in the ['firewall']['rules'] attribute, which must contain an array of hashes. Each named hash can have the following attributes:
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>protocol</tt></td>
    <td>String</td>
    <td>Protocol to match</td>
    <td>tcp</td>
  </tr>
  <tr>
    <td><tt>action</tt></td>
    <td>String</td>
    <td>Action for the rule to take; uses ufw-style actions (allow, deny, etc)</td>
    <td>allow</td>
  </tr>
  <tr>
    <td><tt>port</tt></td>
    <td>String</td>
    <td>Destination port</td>
    <td>none</td>
  </tr>
  <tr>
    <td><tt>source</tt></td>
    <td>String</td>
    <td>Source IP address of the incoming request</td>
    <td>none</td>
  </tr>
  <tr>
    <td><tt>src_port</tt></td>
    <td>String</td>
    <td>Source port of the incoming request</td>
    <td>none</td>
  </tr>
  <tr>
    <td><tt>destination</tt></td>
    <td>String</td>
    <td>Destination IP address</td>
    <td>none</td>
  </tr>
  <tr>
    <td><tt>parameters</tt></td>
    <td>String</td>
    <td>Additional parameters to add after the --jump parameter</td>
    <td>none</td>
  </tr>
  <tr>
    <td><tt>static_rule</tt></td>
    <td>String</td>
    <td>Complete rule string to use; ignores all parameters above</td>
    <td>none</td>
  </tr>
  <tr>
    <td><tt>chain</tt></td>
    <td>String</td>
    <td>Chain to add the rule to</td>
    <td>INPUT</td>
  </tr>
  <tr>
    <td><tt>table</tt></td>
    <td>String</td>
    <td>Table to add the rule to</td>
    <td>filter</td>
  </tr>
</table>

Usage
-----
Create firewall rule attributes in a role and add the iptables-biola::default recipe to the node's or role's run-list.