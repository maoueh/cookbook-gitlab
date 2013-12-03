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
  notifies :stop, "service[gitlab]", :immediately if File.exists?("/etc/init.d/gitlab")
  notifies :delete, "file[gems]", :immediately
  notifies :delete, "file[migrate]", :immediately
  notifies :start, "service[gitlab]"
end

file "gems" do
  path File.join(gitlab['home'], ".gitlab_gems_#{gitlab['env']}")
  action :nothing
end

file "migrate" do
  path File.join(gitlab['home'], ".gitlab_migrate_#{gitlab['env']}")
  action :nothing
end
