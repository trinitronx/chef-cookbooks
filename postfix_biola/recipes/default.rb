#
# Cookbook Name:: postfix_biola
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

service "postfix" do
	supports :status => true, :stop => true, :start => true, :reload => true, :restart => true, :status => true, :force-reload => true,
end

postfix_whitelist = Array.new

postfix_whitelist = search(:node, "relayhost_role:postfix_relayhost")

template "/etc/postfix/whitelist" do
	source whitelist.erb
	owner "root"
	group "root"
	mode "00644"
	variables	:postfix_whitelist => postfix_whitelist
	notifies :force-reload, "service[postfix]"
end