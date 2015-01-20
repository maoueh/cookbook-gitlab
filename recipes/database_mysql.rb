#
# Cookbook Name:: gitlab
# Recipe:: database_mysql
#

mysql = node['mysql']
gitlab = node['gitlab']

# 5.Database
unless gitlab['external_database']
  if node["platform_family"] == 'rhel'
    include_recipe "selinux::#{node['selinux']['state'].downcase}"
  end

  mysql_service mysql['server']['instance'] do
    port mysql['server']['port']
    version mysql['server']['version']
    data_dir mysql['server']['data_dir']
    charset mysql['server']['charset']
    initial_root_password mysql['server']['password']
    action [:create, :start]
  end

  mysql_config "gitlab" do
    instance mysql['server']['instance']
    config_name 'gitlab'
    source 'gitlab.cnf.erb'
    action :create

    notifies :restart, "mysql_service[#{mysql['server']['instance']}]", :immediately
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
  host mysql['database_allowed_host']
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
    host mysql['database_allowed_host']
    privileges ["SELECT", "UPDATE", "INSERT", "DELETE", "CREATE", "DROP", "INDEX", "ALTER", "LOCK TABLES"]
    action :grant
  end
end
