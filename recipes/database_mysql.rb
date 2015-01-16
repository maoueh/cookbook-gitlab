#
# Cookbook Name:: gitlab
# Recipe:: database_mysql
#

mysql = node['mysql']
gitlab = node['gitlab']

# 5.Database
unless gitlab['external_database']
  mysql_service 'gitlab' do
    port mysql['port']
    version mysql['version']
    initial_root_password mysql['initial_root_password']
    action [:create, :start]
  end
end

include_recipe "database::mysql"

mysql_connection = {
  :host => mysql['server']['host'],
  :username => mysql['server']['username'],
  :password => mysql['server']['password'],
  :socket => mysql['server']['socket']
}

## Create a user for GitLab.
mysql_database_user gitlab['database_user'] do
  connection mysql_connection
  password gitlab['database_password']
  host mysql['client']['host']
  action :create
end

## Create the GitLab database & grant all privileges on database
gitlab['environments'].each do |environment|
  mysql_database "gitlabhq_#{environment}" do
    database_name "gitlabhq_#{environment}"
    encoding "utf8"
    collation "utf8_unicode_ci"
    connection mysql_connection
    action :create
  end

  mysql_database_user gitlab['database_user'] do
    connection mysql_connection
    password gitlab['database_password']
    database_name "gitlabhq_#{environment}"
    host mysql['client']['host']
    privileges ["SELECT", "UPDATE", "INSERT", "DELETE", "CREATE", "DROP", "INDEX", "ALTER", "LOCK TABLES"]
    action :grant
  end
end
