#
# Cookbook Name:: gitlab
# Recipe:: _gitlab_git_http_server
#

gitlab = node['gitlab']
git_http_server = node['gitlab']['git_http_server']

git git_http_server['path'] do
  repository git_http_server['repository']
  revision git_http_server['revision']
  user gitlab['user']
  group gitlab['group']
  action :sync
end

bash "install gitlab-git-http-server #{git_http_server['revision']}" do
  flags '-e'
  code <<-EOC
    cd #{git_http_server['path']}
    make
  EOC
end
