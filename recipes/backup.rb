# -*- mode: ruby; coding: utf-8; -*-
#
# Cookbook Name:: gitlab
# Recipe:: backup
#

gitlab = node['gitlab']

if gitlab['env'] == 'production'
  cron 'gitlab_backups' do
    action node['gitlab']['backup']['cron']['action']
    minute node['gitlab']['backup']['cron']['minute']
    hour node['gitlab']['backup']['cron']['hour']
    user node['gitlab']['user']
    mailto node['gitlab']['backup']['cron']['mailto']
    path node['gitlab']['backup']['cron']['path']
    command "cd #{gitlab['home']}/gitlab && bundle exec rake gitlab:backup:create RAILS_ENV=#{gitlab['env']}"
  end
end
