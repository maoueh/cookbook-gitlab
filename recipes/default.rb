#
# Cookbook Name:: gitlab
# Recipe:: default
#

gitlab = node['gitlab']

if node['platform_family'] == 'rhel'
  # Too lazy for now to make SELinux work correctly (sorry http://stopdisablingselinux.com)
  #  - MySQL database paths contexts must be defined
  #  - Nginx paths contexts must be defined.
  #
  # Thinking about using https://github.com/BackSlasher/chef-selinuxpolicy
  #
  include_recipe "selinux::#{node['selinux']['state'].downcase}"
end

include_recipe 'gitlab::_users'

include_recipe 'gitlab::_packages'
include_recipe 'gitlab::_gems'

include_recipe "gitlab::_database_#{gitlab['database_adapter']}"
include_recipe 'gitlab::_redis'

include_recipe 'gitlab::_gitlab_workhorse'
include_recipe 'gitlab::_gitlab_shell'
include_recipe 'gitlab::_clone'
include_recipe 'gitlab::_install'

include_recipe 'gitlab::_nginx'
