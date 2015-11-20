#
# Cookbook Name:: gitlab
# Recipe:: database_postgresql
#

postgresql = node['postgresql']
gitlab = node['gitlab']

# 5.Database
unless gitlab['external_database']
  include_recipe 'postgresql::server'
end

include_recipe 'database::postgresql'
include_recipe 'postgresql::ruby'

postgresql_connection = {
  :host => postgresql['server']['host'],
  :username => postgresql['username']['postgres'],
  :password => postgresql['password']['postgres']
}

postgresql_database_user gitlab['database_user'] do
  connection postgresql_connection
  password gitlab['database_password']
  action :create
end

postgresql_database 'gitlabhq_production' do
  database_name 'gitlabhq_production'
  template 'template0'
  encoding 'utf8'
  collation 'en_US.UTF-8'
  connection postgresql_connection
  action :create
end

postgresql_database_user gitlab['database_user'] do
  connection postgresql_connection
  database_name 'gitlabhq_production'
  password gitlab['database_password']
  action :grant
end
