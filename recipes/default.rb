#
# Cookbook Name:: gitlab
# Recipe:: default
#

gitlab = node['gitlab']

include_recipe "gitlab::_users"

include_recipe "gitlab::_packages"
include_recipe "gitlab::_gems"

include_recipe "gitlab::_database_#{gitlab['database_adapter']}"
include_recipe "gitlab::_redis"

include_recipe "gitlab::_gitlab_shell"
include_recipe "gitlab::_clone"
include_recipe "gitlab::_install"

include_recipe "gitlab::_nginx"
