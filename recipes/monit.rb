#
# Cookbook Name:: gitlab
# Recipe:: monit
#
gitlab = node['gitlab']
monitrc = gitlab['monitrc']

include_recipe "monit::default"

monit_monitrc "sidekiq" do
  variables ({
    gitlab_user: gitlab['user'],
    gitlab_path: gitlab['path'],
    sidekiq_pid_path: monitrc['sidekiq_pid_path'],
    notify_email: monitrc['notify_email']
  })
end

monit_monitrc "unicorn" do
  variables ({
    gitlab_user: gitlab['user'],
    gitlab_path: gitlab['path'],
    unicorn_pid_path: monitrc['unicorn_pid_path'],
    notify_email: monitrc['notify_email']
  })
end

directory "#{gitlab['path']}/bin" do
  user gitlab['user']
  group gitlab['group']
  mode 0755
  action :create
end

file "#{gitlab['path']}/bin/test_sidekiq_max_workers.sh" do
  mode 0755
  action :create_if_missing
end
