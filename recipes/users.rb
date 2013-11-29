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
  gid gitlab['group']
  supports :manage_home => true
end

user gitlab['user'] do
  action :lock
end
