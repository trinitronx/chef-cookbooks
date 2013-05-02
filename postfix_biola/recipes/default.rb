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

mail_sender = Array.new

mail_sender = search(:node, "roles:mail_sender")

device_whitelist = Array.new

device_whitelist = search(:postfix_whitelist, "*:*")

template "/etc/postfix/whitelist" do
	source "whitelist.erb"
	owner "root"
	group "root"
	mode "00644"
	variables 	:device_whitelist => device_whitelist,
	:mail_sender => mail_sender
	notifies :reload, "service[postfix]"
end
