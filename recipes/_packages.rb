#
# Cookbook Name:: gitlab
# Recipe:: packages
#

gitlab = node['gitlab']

magic_shell_environment 'PATH' do
  value '/usr/local/bin:/usr/local/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin'
end

include_recipe 'apt' if platform?('ubuntu', 'debian')
include_recipe 'yum-epel' if platform_family?('rhel')

gitlab['packages'].each do |pkg|
  package pkg
end

package 'openssl' do
  action :upgrade
end

# Git source before ruby_build to avoid installing a default git package
include_recipe 'git::source'

include_recipe 'golang::default'
include_recipe 'ruby_build::default'

ruby_build_ruby gitlab['ruby'] do
  prefix_path '/usr/local/'
end

gem_package 'bundler' do
  gem_binary '/usr/local/bin/gem'
  options '--no-ri --no-rdoc'
end
