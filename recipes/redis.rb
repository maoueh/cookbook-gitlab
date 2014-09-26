#
# Cookbook Name:: gitlab
# Recipe:: redis
#
gitlab = node['gitlab']

include_recipe "redisio::install"

directory gitlab['redis_socket_directory'] do
  path gitlab['redis_socket_directory']
  owner node['redisio']['default_settings']['user']
  group gitlab['group']
  mode 0750
  action :create
end

include_recipe "redisio::enable"

service "redis#{gitlab['redis_port']}" do
  action :nothing
  subscribes :restart, "directory[#{gitlab['redis_socket_directory']}]", :immediately
end
