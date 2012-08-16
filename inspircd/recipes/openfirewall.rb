#
# Cookbook Name:: inspircd
# Recipe:: openfirewall 
#
# Copyright 2012, Biola University
#
# All rights reserved - Do Not Redistribute
#

# Convert ssl port to integer
portValue = node[:inspircd][:ssl_port]
portValue = portValue.to_i

firewall_rule "irc_host_ssl" do
  port portValue
  action :allow
end
