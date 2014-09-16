# -*- mode: ruby; coding: utf-8; -*-
#
# Cookbook Name:: gitlab
# Recipe:: backup
#

gitlab = node['gitlab']

cron 'gitlab_backups' do
  action node['gitlab']['backup']['cron']['action']
  minute node['gitlab']['backup']['cron']['minute']
  hour node['gitlab']['backup']['cron']['hour']
  user node['gitlab']['user']
  mailto node['gitlab']['backup']['cron']['mailto']
  path node['gitlab']['backup']['cron']['path']
  command "cd #{gitlab['home']}/gitlab && bundle exec rake gitlab:backup:create RAILS_ENV=#{gitlab['env']}"

  only_if { gitlab['backup']['enable'] and gitlab['env'] == 'production' }
end
