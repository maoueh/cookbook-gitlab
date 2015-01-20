# -*- mode: ruby; coding: utf-8; -*-
#
# Cookbook Name:: gitlab
# Recipe:: backup
#

gitlab = node['gitlab']
backup = gitlab['backup']

cron 'gitlab_backups' do
  action backup['cron']['action']
  minute backup['cron']['minute']
  hour backup['cron']['hour']
  user gitlab['user']
  mailto backup['cron']['mailto']
  path backup['cron']['path']
  command "cd #{gitlab['home']}/gitlab && #{GitLab.bundle_exec_rake(node, "gitlab:backup:create")}"

  only_if { backup['enable'] }
end
