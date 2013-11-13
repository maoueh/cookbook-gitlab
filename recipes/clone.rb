#
# Cookbook Name:: gitlab
# Recipe:: clone
#

gitlab = node['gitlab']

# 6. GitLab
## Clone the Source
git gitlab['path'] do
  repository gitlab['repository']
  revision gitlab['revision']
  user gitlab['user']
  group gitlab['group']
  action :sync
end
