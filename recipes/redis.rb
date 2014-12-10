#
# Cookbook Name:: gitlab
# Recipe:: redis
#
gitlab = node['gitlab']

include_recipe "redisio::install"

# Add gitlab users to redis group
group node['redisio']['default_settings']['group'] do
  action :modify
  members gitlab['user']
  append true
  not_if gitlab['redis_unixsocket'].nil?
end

## Note: Due to mixlib-shellout issue #68, we must use gitlab group
##       here. The reason is that when we will execute commands as
##       gitlab user later on, mixlib-shellout will not set supplementary
##       group which will make execution fail.
##
##       Once resolved, we will be able to change logic a bit a be more
##       kosher.
##
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
