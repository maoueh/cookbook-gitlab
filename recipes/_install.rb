#
# Cookbook Name:: gitlab
# Recipe:: install
#

gitlab = node['gitlab']

##
#  * Installation
#     - bundle install (current: when gitlab clone resource ran)
#     - rake db:setup (current: when database creation resource ran)
#     - rake db:seed_fu (current: when db:setup resource ran)
#     - rake db:migrate (current when either db:setup or gitlab clone resources ran)
#     - rake assets:clean (current when db:migration resource ran)
#     - rake assets:precompile (current when db:migration resource ran)
#     - rake cache:clear (current when db:migration resource ran)
#
#  * Update
#     - bundle install (current: when gitlab clone resource ran)
#     - rake db:migrate (current when either db:setup or gitlab clone resources ran)
#     - rake assets:clean (current when db:migration resource ran)
#     - rake assets:precompile (current when db:migration resource ran)
#     - rake cache:clear (current when db:migration resource ran)
#

%w(log tmp tmp/pids tmp/sockets public/uploads).each do |folder|
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

template "#{gitlab['path']}/config/gitlab.yml" do
  source 'gitlab.yml.erb'
  user gitlab['user']
  group gitlab['group']
  variables(
    'host' => gitlab['host'],
    'port' => gitlab['port'],
    'user' => gitlab['user'],
    'email_enabled' => gitlab['email_enabled'],
    'email_display_name' => gitlab['email_display_name'],
    'email_from' => gitlab['email_from'],
    'email_reply_to' => gitlab['email_reply_to'],
    'timezone' => gitlab['timezone'],
    'issue_closing_pattern' => gitlab['issue_closing_pattern'],
    'max_size' => gitlab['max_size'],
    'git_timeout' => gitlab['git_timeout'],
    'git_bin_path' => gitlab['git_bin_path'],
    'satellites_path' => gitlab['satellites_path'],
    'repos_path' => gitlab['repos_path'],
    'shell_path' => gitlab['shell_path'],
    'shell_secret_file' => gitlab['shell_secret_file'],
    'user_can_create_group' => gitlab['user_can_create_group'],
    'user_can_change_username' => gitlab['user_can_change_username'],
    'default_theme' => gitlab['default_theme'],
    'repository_downloads_path' => gitlab['repository_downloads_path'],
    'oauth_enabled' => gitlab['oauth_enabled'],
    'oauth_block_auto_created_users' => gitlab['oauth_block_auto_created_users'],
    'oauth_auto_link_ldap_user' => gitlab['oauth_auto_link_ldap_user'],
    'oauth_allow_single_sign_on' => gitlab['oauth_allow_single_sign_on'],
    'oauth_providers' => gitlab['oauth_providers'],
    'google_analytics_id' => gitlab['extra']['google_analytics_id'],
    'default_projects_features' => gitlab['default_projects_features'],
    'reply_by_email' => gitlab['reply_by_email'],
    'webhook_timeout' => gitlab['webhook_timeout'],
    'gravatar' => gitlab['gravatar'],
    'gravatar_plain_url' => gitlab['gravatar_plain_url'],
    'gravatar_ssl_url' => gitlab['gravatar_ssl_url'],
    'ci' => gitlab['ci'],
    'ldap_config' => gitlab['ldap'],
    'ssh_port' => gitlab['ssh_port'],
    'backup' => gitlab['backup']
  )

  notifies :run, 'bash[git config]', :immediately
  notifies :restart, 'service[gitlab]', :delayed
end

template "#{gitlab['path']}/config/secrets.yml" do
  source 'secrets.yml.erb'
  user gitlab['user']
  group gitlab['group']
  mode 0600
  variables(
    'secret_key' => gitlab['secret_key']
  )

  notifies :restart, 'service[gitlab]', :delayed
end

bash 'git config' do
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
  variables(
    'user' => gitlab['database_user'],
    'password' => gitlab['database_password'],
    'host' => node[gitlab['database_adapter']]['server']['host'],
    'socket' => gitlab['database_adapter'] == 'mysql' ? node['mysql']['server']['socket'] : nil
  )

  notifies :restart, 'service[gitlab]', :delayed
end

file "#{gitlab['path']}/config/resque.yml" do
  content "production: unix:#{gitlab['redis_unixsocket']}"
  user gitlab['user']
  group gitlab['group']

  notifies :restart, 'service[gitlab]', :delayed
end

template "#{gitlab['path']}/config/unicorn.rb" do
  source 'unicorn.rb.erb'
  user gitlab['user']
  group gitlab['group']
  variables(
    'app_root' => gitlab['path'],
    'unicorn_workers_number' => gitlab['unicorn_workers_number'],
    'unicorn_timeout' => gitlab['unicorn_timeout']
  )

  notifies :restart, 'service[gitlab]', :delayed
end

template "#{gitlab['path']}/config/initializers/rack_attack.rb" do
  source 'rack_attack.rb.erb'
  user gitlab['user']
  group gitlab['group']
  mode 0644

  notifies :restart, 'service[gitlab]', :delayed
end

if gitlab['smtp']['enabled']
  smtp = gitlab['smtp']
  template "#{gitlab['path']}/config/initializers/smtp_settings.rb" do
    source 'smtp_settings.rb.erb'
    user gitlab['user']
    group gitlab['group']
    variables(
      'address' => smtp['address'],
      'port' => smtp['port'],
      'username' => smtp['username'],
      'password' => smtp['password'],
      'domain' => smtp['domain'],
      'authentication' => smtp['authentication'],
      'enable_starttls_auto' => smtp['enable_starttls_auto']
    )

    notifies :restart, 'service[gitlab]', :delayed
  end
end

execute 'bundle install' do
  command GitLab.bundle_install(node)
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']

  only_if { GitLab.install?(self) || GitLab.upgrade?(self) }
  notifies :restart, 'service[gitlab]', :delayed
end

execute 'rake db:setup' do
  command GitLab.bundle_exec_rake(node, 'db:setup')
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']

  only_if { GitLab.install?(self) }
end

execute 'rake db:seed_fu' do
  command GitLab.bundle_exec_rake(node, 'db:seed_fu')
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  environment('GITLAB_ROOT_PASSWORD' => gitlab['admin_root_password'])

  only_if { GitLab.install?(self) }
end

execute 'rake db:migrate' do
  command GitLab.bundle_exec_rake(node, 'db:migrate')
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']

  only_if { GitLab.install?(self) || GitLab.upgrade?(self) }
  notifies :restart, 'service[gitlab]', :delayed
end

execute 'rake assets:clean' do
  command GitLab.bundle_exec_rake(node, 'assets:clean')
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']

  only_if { GitLab.install?(self) || GitLab.upgrade?(self) }
  notifies :restart, 'service[gitlab]', :delayed
end

execute 'rake assets:precompile' do
  command GitLab.bundle_exec_rake(node, 'assets:precompile')
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']

  only_if { GitLab.install?(self) || GitLab.upgrade?(self) }
  notifies :restart, 'service[gitlab]', :delayed
end

execute 'rake cache:clear' do
  command GitLab.bundle_exec_rake(node, 'cache:clear')
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']

  only_if { GitLab.install?(self) || GitLab.upgrade?(self) }
  notifies :restart, 'service[gitlab]', :delayed
end

template '/etc/logrotate.d/gitlab' do
  source 'logrotate.erb'
  mode 0644
  variables(
    'gitlab_path' => gitlab['path'],
    'gitlab_shell_path' => gitlab['shell_path']
  )
end

template '/etc/init.d/gitlab' do
  source 'gitlab.init.d.erb'
  mode 0755
  variables(
    'required_services' => GitLab.required_services(node)
  )
end

template '/etc/default/gitlab' do
  source 'gitlab.default.erb'
  mode 0755
  variables(
    'app_user' => gitlab['user'],
    'app_root' => gitlab['path'],
    'mail_room' => gitlab['mail_room'],
    'repos_path' => gitlab['repos_path'],
    'shell_path' => gitlab['shell']
  )
end

service 'gitlab' do
  supports start: true, stop: true, restart: true, reload: true, status: true
  action [:enable, :start]

  subscribes :restart, "directory[#{gitlab['redis_socket_directory']}]"
  subscribes :restart, 'bash[update redis init.d script runuser group]'
end
