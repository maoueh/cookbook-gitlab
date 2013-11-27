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
  gid gitlab['user_gid']
  supports :manage_home => true
end

user gitlab['user'] do
  action :lock
end
