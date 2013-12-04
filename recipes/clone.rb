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
  notifies :delete, "file[gems]", :immediately
  notifies :delete, "file[migrate]", :immediately
  notifies :delete, "file[gitlab start]", :immediately
end

file "gems" do
  path File.join(gitlab['home'], ".gitlab_gems_#{gitlab['env']}")
  action :nothing
end

file "migrate" do
  path File.join(gitlab['home'], ".gitlab_migrate_#{gitlab['env']}")
  action :nothing
end

gitlab_run = file "gitlab start" do
  path File.join(gitlab['home'], ".gitlab_start")
  action :nothing
  notifies :stop, "service[gitlab]", :immediately
end

service "gitlab" do
  action :nothing
  # command "service gitlab stop"
  only_if { gitlab_run.updated_by_last_action? }
end
