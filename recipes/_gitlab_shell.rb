#
# Cookbook Name:: gitlab
# Recipe:: gitlab_shell_clone
#

gitlab = node['gitlab']

git gitlab['shell_path'] do
  repository gitlab['shell_repository']
  revision gitlab['shell_revision']
  user gitlab['user']
  group gitlab['group']
  action :sync
end

template "#{gitlab['shell_path']}/config.yml" do
  source "gitlab_shell.yml.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :user => gitlab['user'],
    :home => gitlab['home'],
    :url => gitlab['url'],
    :repos_path => gitlab['repos_path'],
    :redis_path => gitlab['redis_path'],
    :redis_host => gitlab['redis_host'],
    :redis_port => gitlab['redis_port'],
    :redis_unixsocket => gitlab['redis_unixsocket'],
    :redis_database => gitlab['redis_database'],
    :namespace => gitlab['namespace'],
    :self_signed_cert => gitlab['self_signed_cert']
  })
end

directory "Repositories path" do
  path gitlab['repos_path']
  owner gitlab['user']
  group gitlab['group']
  mode 0770
end

directory "SSH key directory" do
  path "#{gitlab['home']}/.ssh"
  owner gitlab['user']
  group gitlab['group']
  mode 0700
end

file "authorized keys file" do
  path "#{gitlab['home']}/.ssh/authorized_keys"
  owner gitlab['user']
  group gitlab['group']
  mode 0600
  action :create_if_missing
end
