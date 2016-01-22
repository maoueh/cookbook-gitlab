#
# Cookbook Name:: gitlab
# Recipe:: _gitlab_workhorse
#

gitlab = node['gitlab']
workhorse = node['gitlab']['workhorse']

git workhorse['path'] do
  repository workhorse['repository']
  revision workhorse['revision']
  user gitlab['user']
  group gitlab['group']
  action :sync
end

bash "install gitlab-workhorse #{workhorse['revision']}" do
  flags '-e'
  code <<-EOC
    source /etc/profile.d/golang.sh
    cd #{workhorse['path']}
    make
  EOC
end
