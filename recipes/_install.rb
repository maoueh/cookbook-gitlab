#
# Cookbook Name:: gitlab
# Recipe:: install
#

gitlab = node['gitlab']

template "#{gitlab['path']}/config/gitlab.yml" do
  source "gitlab.yml.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :host => gitlab['host'],
    :port => gitlab['port'],
    :user => gitlab['user'],
    :email_enabled => gitlab['email_enabled'],
    :email_from => gitlab['email_from'],
    :timezone => gitlab['timezone'],
    :issue_closing_pattern => gitlab['issue_closing_pattern'],
    :max_size => gitlab['max_size'],
    :git_timeout => gitlab['git_timeout'],
    :satellites_path => gitlab['satellites_path'],
    :satellites_timeout => gitlab['satellites_timeout'],
    :repos_path => gitlab['repos_path'],
    :shell_path => gitlab['shell_path'],
    :signup_enabled => gitlab['signup_enabled'],
    :signin_enabled => gitlab['signin_enabled'],
    :projects_limit => gitlab['projects_limit'],
    :user_can_create_group => gitlab['user_can_create_group'],
    :user_can_change_username => gitlab['user_can_change_username'],
    :default_theme => gitlab['default_theme'],
    :repository_downloads_path => gitlab['repository_downloads_path'],
    :oauth_enabled => gitlab['oauth_enabled'],
    :oauth_block_auto_created_users => gitlab['oauth_block_auto_created_users'],
    :oauth_allow_single_sign_on => gitlab['oauth_allow_single_sign_on'],
    :oauth_providers => gitlab['oauth_providers'],
    :google_analytics_id => gitlab['extra']['google_analytics_id'],
    :sign_in_text => gitlab['extra']['sign_in_text'],
    :default_projects_features => gitlab['default_projects_features'],
    :webhook_timeout => gitlab['webhook_timeout'],
    :gravatar => gitlab['gravatar'],
    :gravatar_plain_url => gitlab['gravatar_plain_url'],
    :gravatar_ssl_url => gitlab['gravatar_ssl_url'],
    :ldap_config => gitlab['ldap'],
    :ssh_port => gitlab['ssh_port'],
    :backup => gitlab['backup'],
  })

  notifies :run, "bash[git config]", :immediately
  notifies :reload, "service[gitlab]"
end

%w{log tmp tmp/pids tmp/sockets public/uploads}.each do |folder|
  directory "#{gitlab['path']}/#{folder}" do
    owner gitlab['user']
    group gitlab['group']
    mode 0755
  end
end

directory gitlab['satellites_path'] do
  owner gitlab['user']
  group gitlab['group']
  mode 0750
end

template "#{gitlab['path']}/config/unicorn.rb" do
  source "unicorn.rb.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :app_root => gitlab['path'],
    :unicorn_workers_number => gitlab['unicorn_workers_number'],
    :unicorn_timeout => gitlab['unicorn_timeout']
  })

  notifies :reload, "service[gitlab]"
end

template "#{gitlab['path']}/config/initializers/rack_attack.rb" do
  source "rack_attack.rb.erb"
  user gitlab['user']
  group gitlab['group']
  mode 0644

  notifies :reload, "service[gitlab]"
end

bash "git config" do
  code <<-EOS
    git config --global user.name "GitLab"
    git config --global user.email "gitlab@#{gitlab['host']}"
    git config --global core.autocrlf input
  EOS
  user gitlab['user']
  group gitlab['group']
  environment('HOME' => gitlab['home'])

  action :nothing
end

template "#{gitlab['path']}/config/database.yml" do
  source "database.yml.#{gitlab['database_adapter']}.erb"
  user gitlab['user']
  group gitlab['group']
  variables({
    :user => gitlab['database_user'],
    :password => gitlab['database_password'],
    :host => node[gitlab['database_adapter']]['server']['host'],
    :socket => gitlab['database_adapter'] == "mysql" ? node['mysql']['server']['socket'] : nil
  })

  notifies :reload, "service[gitlab]"
end

file "#{gitlab['path']}/config/resque.yml" do
  content "production: unix:#{gitlab['redis_unixsocket']}"
  user gitlab['user']
  group gitlab['group']
end

execute "rake db:schema:load" do
  command GitLab.bundle_exec_rake(node, "db:schema:load")
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing

  subscribes :run, "mysql_database[gitlabhq_production]"
  subscribes :run, "postgresql_database[gitlabhq_production]"
end

execute "rake db:migrate" do
  command GitLab.bundle_exec_rake(node, "db:migrate")
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing

  subscribes :run, "git[clone gitlabhq source]"
  subscribes :run, "execute[rake db:schema:load]"
end

execute "rake db:seed_fu" do
  command GitLab.bundle_exec_rake(node, "db:seed_fu")
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  environment ({'GITLAB_ROOT_PASSWORD' => gitlab['admin_root_password']})
  action :nothing

  subscribes :run, "execute[rake db:schema:load]"
end

template "/etc/init.d/gitlab" do
  source "gitlab.init.d.erb"
  mode 0755
end

template "/etc/default/gitlab" do
  source "gitlab.default.erb"
  mode 0755

  variables(
    :app_user => gitlab['user'],
    :app_root => gitlab['path']
  )
end

template "/etc/logrotate.d/gitlab" do
  source "logrotate.erb"
  mode 0644

  variables(
    :gitlab_path => gitlab['path'],
    :gitlab_shell_path => gitlab['shell_path']
  )
end

# SMTP email settings
if gitlab['smtp']['enabled']
  smtp = gitlab['smtp']
  template "#{gitlab['path']}/config/initializers/smtp_settings.rb" do
    source "smtp_settings.rb.erb"
    user gitlab['user']
    group gitlab['group']
    variables({
      :address => smtp['address'],
      :port => smtp['port'],
      :username => smtp['username'],
      :password => smtp['password'],
      :domain => smtp['domain'],
      :authentication => smtp['authentication'],
      :enable_starttls_auto => smtp['enable_starttls_auto']
    })
    notifies :reload, "service[gitlab]"
  end
end

execute "rake assets:clean" do
  command GitLab.bundle_exec_rake(node, "assets:clean")
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
  subscribes :run, "execute[rake db:migrate]", :immediately
end

execute "rake assets:precompile" do
  command GitLab.bundle_exec_rake(node, "assets:precompile")
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
  subscribes :run, "execute[rake db:migrate]", :immediately
end

execute "rake cache:clear" do
  command GitLab.bundle_exec_rake(node, "cache:clear")
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
  subscribes :run, "execute[rake db:migrate]", :immediately
end

service "gitlab" do
  supports :start => true, :stop => true, :restart => true, :reload => true, :status => true
  action :enable

  subscribes :start, "execute[rake db:migrate]"
  subscribes :reload, "execute[rake assets:precompile]"
  subscribes :restart, "directory[#{gitlab['redis_socket_directory']}]"
end

