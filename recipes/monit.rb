#
# Cookbook Name:: gitlab
# Recipe:: monit
#
monitrc = node['gitlab']['monitrc']

include_recipe "monit::default"

monit_monitrc "sidekiq" do
  variables ({
    sidekiq_pid_path: monitrc['sidekiq_pid_path'],
    notify_email: monitrc['notify_email']
  })
end

monit_monitrc "unicorn" do
  variables ({
    unicorn_pid_path: monitrc['unicorn_pid_path'],
    notify_email: monitrc['notify_email']
  })
end
