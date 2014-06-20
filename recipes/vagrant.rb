#
# Cookbook Name:: gitlab
# Recipe:: vagrant
#

gitlab = node['gitlab']

# Add gitlab start command alias
template File.join(gitlab['home'], '.bash_aliases') do
  source 'bash_aliases.erb'
  user gitlab['user']
  group gitlab['group']
  variables(
    :gitlab_path => gitlab['path'],
  )
end
