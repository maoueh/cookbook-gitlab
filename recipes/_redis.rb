#
# Cookbook Name:: gitlab
# Recipe:: redis
#

gitlab = node['gitlab']
redisio = node['redisio']

include_recipe "redisio"

# Add gitlab users to redis group
group redisio['default_settings']['group'] do
  action :modify
  members gitlab['user']
  append true
  not_if gitlab['redis_unixsocket'].nil?
end

include_recipe "redisio::enable"

###
## Note: Due to mixlib-shellout issue #68, we must use gitlab group
##       here instead of redis group. The reason is that when we will execute
##       commands as gitlab user later on, mixlib-shellout will not set
##       supplementary groups gitlab user has access to which in the end will
##       make execution fail. Once resolved, we will be able to change logic a
##       bit to be more kosher.

directory gitlab['redis_socket_directory'] do
  owner redisio['default_settings']['user']
  group gitlab['group']
  mode gitlab['redis_unixsocketperms']

  only_if { gitlab['redis_unixsocket'] }

  notifies :restart, "service[redis#{gitlab['redis_port']}]", :immediately
end

###
##       It appears that the mixlib-shellout bug is harder to workaround than
##       anticipated. Usually, socket permission can't be changed and it's
##       the parent directory that is used. However, changing the directory
##       does not seems to work. Socket permission are created using the
##       running uid and gid. Hence, we need to edit redis service definition
##       and force it to run in git group.

bash "change redis init.d exec command" do
  code GitLab.redis_sed_exec(node)

  notifies :restart, "service[redis#{gitlab['redis_port']}]", :immediately
end
