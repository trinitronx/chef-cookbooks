#
# Cookbook Name:: solr_biola
# Recipe:: default
#
# Copyright 2012, Biola University
#
# All rights reserved - Do Not Redistribute
#

# Make sure solr-tomcat package is installed
package 'solr-tomcat'

# Make sure tomcat is running
service 'tomcat6' do
  supports :status => true, :restart => true
  action :start
end

# Make sure the /srv/solr/ directory exists
directory "/srv/solr" do
  owner "tomcat6"
  group "ruby-dev" #TODO: check that ruby-dev group exists first.
  mode "0775"
  action :create
end

# Make sure we can see inside the tomcat log directory
directory "/var/log/tomcat6" do
  mode "0755"
  action :create
end