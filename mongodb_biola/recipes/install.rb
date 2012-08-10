package "mongodb-10gen" do
  action :install
end

template "/etc/mongodb.conf" do
  source "mongodb.conf.erb"
  owner "root"
  group "root"
  mode 0755
  notifies :restart, "service[mongodb]"
end

service "mongodb" do
  supports :restart => true
  action :enable
end