#
# Cookbook Name:: postfix_biola
# Recipe:: default
#
# Copyright 2013, Biola University
#
# All rights reserved - Do Not Redistribute
#

service "postfix" do
	supports :status => true, :stop => true, :start => true, :reload => true, :restart => true, :status => true
end

postfix_whitelist = Array.new

postfix_whitelist = search(:node, "postfix_relayhost_role:postfix_relayhost")

device_whitelist = Array.new

device_whitelist = search(:postfix_whitelist, "*:*")

template "/etc/postfix/whitelist" do
	source "whitelist.erb"
	owner "root"
	group "root"
	mode "00644"
	variables 	:postfix_whitelist => postfix_whitelist,
	:device_whitelist => device_whitelist
	notifies :reload, "service[postfix]"
end