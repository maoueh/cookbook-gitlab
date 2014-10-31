#
# Cookbook Name:: gitlab
# Recipe:: setup
#
# This recipe is used for AWS OpsWorks setup section
# Any change must be tested against AWS OpsWorks stack

gitlab = node['gitlab']

# Install GitLab required packages
include_recipe "gitlab::packages"

# Compile ruby
include_recipe "gitlab::ruby" if gitlab['compile_ruby']

# Setup Redis
include_recipe "gitlab::redis"

# Setup chosen database
include_recipe "gitlab::database_#{gitlab['database_adapter']}"

# Setup GitLab user (must come last)
include_recipe "gitlab::users"
