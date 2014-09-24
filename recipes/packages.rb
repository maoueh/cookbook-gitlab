#
# Cookbook Name:: gitlab
# Recipe:: packages
#

gitlab = node['gitlab']

# Make sure we have all common paths included in our environment
magic_shell_environment 'PATH' do
  value '/usr/local/bin:/usr/local/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin'
end

# 1. Packages / Dependencies
include_recipe "apt" if platform?("ubuntu", "debian")
include_recipe "yum-epel" if platform_family?("rhel")
include_recipe "gitlab::git"
include_recipe "redisio::install"

directory "create_redis_socket_dir" do
  path gitlab['redis_socket_directory']
  owner node['redisio']['default_settings']['user']
  group gitlab['group']
  mode 0750
  action :create
end

include_recipe "redisio::enable"

service "redis#{gitlab['redis_port']}" do
  action :nothing
  subscribes :restart, "directory['create_redis_socket_dir']", :immediately
end

## Install the required packages.
gitlab['packages'].each do |pkg|
  package pkg
end

# Upgrade the openssl package to the latest version in the repository to prevent bundle install failures due to invalid certs
package "openssl" do
  action :upgrade
end
