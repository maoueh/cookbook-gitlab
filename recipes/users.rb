#
# Cookbook Name:: gitlab
# Recipe:: users
#

gitlab = node['gitlab']

# 3. System Users
## Create user for Gitlab.
user gitlab['user'] do
  comment "GitLab user"
  home gitlab['home']
  shell "/bin/bash"
  supports :manage_home => true
end

user gitlab['user'] do
  action :lock
end
