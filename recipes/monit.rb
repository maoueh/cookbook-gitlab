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
