#
# Cookbook Name:: gitlab
# Recipe:: users
#

gitlab = node['gitlab']

# 3. System Users

## Create group for GitLab user
group gitlab['group'] do
  gid gitlab['user_gid']
end

## Create user for Gitlab.
user gitlab['user'] do
  comment "GitLab user"
  home gitlab['home']
  shell "/bin/bash"
  uid gitlab['user_uid']
  # We already created a user with specific gid so now we can supply the name
  # This line will make sure that we always have the correct group associated to the user
  # This is needed because if group id is nil chef won't supply -g to the useradd, see
  # https://github.com/opscode/chef/blob/11.4.4/lib/chef/provider/user/useradd.rb#L26
  gid gitlab['group']
  supports :manage_home => true
end

# Locking user is not needed in development
user gitlab['user'] do
  action :lock
  only_if { gitlab['env'] == 'production' }
end

group node['redisio']['default_settings']['group'] do
  action :modify
  members gitlab['user']
  append true
  not_if gitlab['redis_unixsocket'].nil?
end
