#
# Cookbook Name:: gitlab
# Recipe:: start
#

gitlab = node['gitlab']

## Start Your GitLab Instance
service "gitlab" do
  supports :start => true, :stop => true, :restart => true, :reload => true, :status => true
  action gitlab['env'] == "production" ? :enable : :nothing
end

service "gitlab" do
  action :nothing
  subscribes :start, "execute[rake db:migrate]"
  subscribes :reload, "execute[rake assets:precompile]"
  subscribes :restart, "directory[#{gitlab['redis_socket_directory']}]"
end
