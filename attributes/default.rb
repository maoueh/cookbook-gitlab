# GitLab Common Attributes

default['gitlab']['force_install'] = false
default['gitlab']['force_upgrade'] = false
default['gitlab']['prevent_install'] = false

## User

default['gitlab']['user'] = 'git'
default['gitlab']['group'] = 'git'
default['gitlab']['user_uid'] = nil # Use to specify user id.
default['gitlab']['user_gid'] = nil # Use to specify group id.
default['gitlab']['home'] = '/home/git'
default['gitlab']['shell'] = '/bin/bash'

# GitLab App Server Attributes

default['gitlab']['revision'] = '8-6-stable'
default['gitlab']['url'] = 'http://localhost:80/'
default['gitlab']['port'] = '80'

default['gitlab']['repository'] = 'https://github.com/gitlabhq/gitlabhq.git'
default['gitlab']['deploy_key'] = '' # Optional. Private key used to connect to private GitLab repository.

default['gitlab']['path'] = "#{node['gitlab']['home']}/gitlab"
default['gitlab']['repos_path'] = "#{node['gitlab']['home']}/repositories"

# Note for maintainers: keep the satellites.path setting until GitLab 9.0 at least, used by migrations
default['gitlab']['satellites_path'] = "#{node['gitlab']['home']}/gitlab-satellites"

default['gitlab']['workhorse']['path'] = "#{node['gitlab']['home']}/gitlab-workhorse"
default['gitlab']['workhorse']['repository'] = 'https://gitlab.com/gitlab-org/gitlab-workhorse.git'
default['gitlab']['workhorse']['revision'] = '0.7.2'

default['gitlab']['mail_room']['enabled'] = false

# Attribute `secret_key` is used to encrypt for Variables. Ensure that
# you don't lose it. If you change or lose this key you will be unable to
# access variables stored in database. Make sure the secret is at least 30
# characters and all random, no regular words or you'll be exposed to dictionary
# attacks.
default['gitlab']['secret_key'] = 'not_random_change_me_now_with_random_30_characters_no_words'

default['gitlab']['shell_repository'] = 'https://github.com/gitlabhq/gitlab-shell.git'
default['gitlab']['shell_path'] = "#{node['gitlab']['home']}/gitlab-shell"
default['gitlab']['shell_revision'] = 'v2.6.11'
default['gitlab']['shell_secret_file'] = "#{node['gitlab']['home']}/gitlab/.gitlab_shell_secret"

default['gitlab']['smtp']['enabled'] = false
default['gitlab']['smtp']['address'] = 'email.server.com'
default['gitlab']['smtp']['port'] = 456
default['gitlab']['smtp']['username'] = 'smtp'
default['gitlab']['smtp']['password'] = '123456'
default['gitlab']['smtp']['domain'] = 'gitlab.example.com'
default['gitlab']['smtp']['authentication'] = 'login'
default['gitlab']['smtp']['enable_starttls_auto'] = true

## Config

default['gitlab']['host'] = 'localhost'
default['gitlab']['email_enabled'] = true
default['gitlab']['email_display_name'] = 'GitLab'
default['gitlab']['email_from'] = 'gitlab@localhost'
default['gitlab']['email_reply_to'] = 'noreply@localhost'
default['gitlab']['ssh_port'] = '22'

default['gitlab']['timezone'] = 'UTC'
default['gitlab']['issue_closing_pattern'] = '((?:[Cc]los(?:e[sd]?|ing)|[Ff]ix(?:e[sd]|ing)?) +(?:(?:issues? +)?%{issue_ref}(?:(?:, *| +and +)?))+)'
default['gitlab']['max_size'] = '20971520' # 20.megabytes
default['gitlab']['git_timeout'] = 10
default['gitlab']['git_bin_path'] = '/usr/local/bin/git'
default['gitlab']['user_can_create_group'] = true
default['gitlab']['user_can_change_username'] = true
default['gitlab']['default_theme'] = 2
default['gitlab']['repository_downloads_path'] = 'tmp/repositories'

default['gitlab']['webhook_timeout'] = 10
default['gitlab']['admin_root_password'] = nil
default['gitlab']['unicorn_workers_number'] = 3
default['gitlab']['unicorn_timeout'] = 60

default['gitlab']['backup']['enable'] = true
default['gitlab']['backup']['cron']['action'] = :create
default['gitlab']['backup']['cron']['minute'] = 0
default['gitlab']['backup']['cron']['hour'] = 2
default['gitlab']['backup']['cron']['mailto'] = 'gitlab@localhost'
default['gitlab']['backup']['cron']['path'] = '/usr/local/bin:/usr/bin:/bin'
default['gitlab']['backup']['backup_keep_time'] = 0
default['gitlab']['backup']['backup_path'] = 'tmp/backups'
default['gitlab']['backup']['archive_permissions'] = '0640'
default['gitlab']['backup']['pg_schema'] = nil

default['gitlab']['build_artifacts']['enabled'] = true
default['gitlab']['build_artifacts']['path'] = 'shared/artifacts'

default['gitlab']['cas3']['session_duration'] = 28_800

default['gitlab']['ci']['all_broken_builds'] = true
default['gitlab']['ci']['add_pusher'] = true
default['gitlab']['ci']['builds_path'] = 'builds/'

default['gitlab']['cron_jobs']['stuck_ci_builds_worker']['cron'] = '0 0 * * *'

default['gitlab']['extra']['google_analytics_id'] = ''

default['gitlab']['features']['issues'] = true
default['gitlab']['features']['merge_requests'] = true
default['gitlab']['features']['wiki'] = true
default['gitlab']['features']['snippets'] = false
default['gitlab']['features']['builds'] = true

default['gitlab']['gravatar']['enabled'] = true
default['gitlab']['gravatar']['plain_url'] = 'http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'
default['gitlab']['gravatar']['ssl_url'] = 'https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'

default['gitlab']['lfs']['enabled'] = true
default['gitlab']['lfs']['path'] = 'shared/lfs-objects'

default['gitlab']['ldap']['enabled'] = false
default['gitlab']['ldap']['label'] = 'LDAP'
default['gitlab']['ldap']['host'] = '_your_ldap_server'
default['gitlab']['ldap']['base'] = '_the_base_where_you_search_for_users'
default['gitlab']['ldap']['port'] = 389
default['gitlab']['ldap']['uid'] = 'sAMAccountName'
default['gitlab']['ldap']['method'] = 'plain'
default['gitlab']['ldap']['bind_dn'] = '_the_full_dn_of_the_user_you_will_bind_with'
default['gitlab']['ldap']['password'] = '_the_password_of_the_bind_user'
default['gitlab']['ldap']['allow_username_or_email_login'] = true
default['gitlab']['ldap']['active_directory'] = true
default['gitlab']['ldap']['allow_username_or_email_login'] = true
default['gitlab']['ldap']['block_auto_created_users'] = false
default['gitlab']['ldap']['user_filter'] = ''
default['gitlab']['ldap']['timeout'] = 10
default['gitlab']['ldap']['attributes']['username'] = "['uid', 'userid', 'sAMAccountName']"
default['gitlab']['ldap']['attributes']['email'] = "['mail', 'email', 'userPrincipalName']"
default['gitlab']['ldap']['attributes']['name'] = 'cn'
default['gitlab']['ldap']['attributes']['first_name'] = 'givenName'
default['gitlab']['ldap']['attributes']['last_name'] = 'sn'

default['gitlab']['reply_by_email']['enabled'] = false
default['gitlab']['reply_by_email']['address'] = 'gitlab-incoming+%{key}@gmail.com'
default['gitlab']['reply_by_email']['user'] = 'gitlab-incoming@gmail.com'
default['gitlab']['reply_by_email']['password'] = '[REDACTED]'
default['gitlab']['reply_by_email']['host'] = 'imap.gmail.com'
default['gitlab']['reply_by_email']['port'] = 993
default['gitlab']['reply_by_email']['ssl'] = true
default['gitlab']['reply_by_email']['start_tls'] = false
default['gitlab']['reply_by_email']['mailbox'] = 'inbox'

default['gitlab']['oauth']['enabled'] = false
default['gitlab']['oauth']['block_auto_created_users'] = true
default['gitlab']['oauth']['auto_link_ldap_user'] = false
default['gitlab']['oauth']['auto_link_saml_user'] = false
default['gitlab']['oauth']['allow_single_sign_on'] = false
default['gitlab']['oauth']['providers'] = []

default['gitlab']['shared']['path'] = '/mnt/gitlab'

## Git

default['git']['prefix'] = '/usr/local'
default['git']['version'] = '2.4.7'
default['git']['url'] = "https://github.com/git/git/archive/v#{node['git']['version']}.tar.gz"
default['git']['checksum'] = 'de2b14efa156aeb15d455cc0b23f08b3098c2212ef4d9d42b7e95bbaa0e67199'

## Go

default['go']['scm'] = false

## Packages

case node['platform_family']
when 'debian'
  default['gitlab']['packages'] = %w(
    build-essential checkinstall cmake curl libcurl4-openssl-dev libffi-dev libgdbm-dev libicu-dev
    libkrb5-dev libncurses5-dev libreadline-dev libssh2-dev libssl-dev libxml2-dev libxslt-dev
    libyaml-dev logrotate nodejs openssh-server postgresql-contrib python-docutils vim wget zlib1g-dev
  )
when 'rhel'
  default['gitlab']['packages'] = %w(
    cmake curl-devel gcc-c++ gdbm-devel ImageMagick ImageMagick-devel krb5-devel libcurl-devel
    libffi-devel libicu-devel libssh2-devel libxml2-devel libxslt-devel libyaml-devel mysql-devel
    nodejs openssl-devel pcre-devel readline-devel zlib-devel
  )
end

## Ruby

default['gitlab']['ruby'] = '2.1.2'
default['gitlab']['update_ruby'] = false

override['ruby_build']['install_git_pkgs'] = []

# GitLab Database Server Attributes

default['gitlab']['external_database'] = false
default['gitlab']['database_adapter'] = 'postgresql' # Or 'mysql'
default['gitlab']['database_password'] = 'datapass'
default['gitlab']['database_user'] = 'git'
default['gitlab']['database_allowed_host'] = 'localhost' # Used by MySQL only

## MySQL
default['mysql']['server']['instance'] = 'gitlab'
default['mysql']['server']['host'] = '127.0.0.1'
default['mysql']['server']['data_dir'] = nil
default['mysql']['server']['charset'] = 'utf8'
default['mysql']['server']['port'] = '3306'
default['mysql']['server']['socket'] = nil
default['mysql']['server']['version'] = '5.5'
default['mysql']['server']['username'] = 'root'
default['mysql']['server']['password'] = 'rootpass'

default['selinux']['state'] = 'disabled'

## PostgreSQL
include_attribute 'postgresql'

default['postgresql']['version'] = '9.3'
default['postgresql']['username']['postgres'] = 'postgres'
default['postgresql']['password']['postgres'] = 'psqlpass'
default['postgresql']['server']['host'] = 'localhost'

default['postgresql']['contrib']['extensions'] = ['pg_trgm']

case node['platform_family']
when 'debian'
  default['postgresql']['enable_pgdg_apt'] = true
  default['postgresql']['client']['packages'] = %w(postgresql-client-9.3 libpq-dev)
  default['postgresql']['server']['packages'] = %w(postgresql-9.3)
  default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['config']['data_directory'] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
  default['postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
  default['postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
  default['postgresql']['config']['ssl'] = false
  default['postgresql']['config']['unix_socket_directory'] = nil
  default['postgresql']['config']['unix_socket_directories'] = '/var/run/postgresql'
  default['gitlab']['postgresql']['configuration_dir'] = nil
when 'rhel'
  default['postgresql']['enable_pgdg_yum'] = true
  default['postgresql']['client']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-devel"]
  default['postgresql']['server']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-server"]
  default['postgresql']['contrib']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-contrib"]
  default['postgresql']['dir'] = '/var/lib/pgsql/data'
  default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
  default['gitlab']['postgresql']['configuration_dir'] = "/usr/pgsql-#{node['postgresql']['version']}/bin"
end

# We need compile time build-essential if database_adapter is postgresql
default['build-essential']['compile_time'] = true if node['gitlab']['database_adapter'] == 'postgresql'

## Redis
include_attribute 'redisio'

default['gitlab']['redis_path'] = '/usr/local/bin/redis-cli'
default['gitlab']['redis_socket_directory'] = "#{default['redisio']['base_piddir']}/sockets"
default['gitlab']['redis_unixsocket'] = "#{default['gitlab']['redis_socket_directory']}/redis.sock"
if node['gitlab']['redis_unixsocket']
  default['gitlab']['redis_port'] = '0'
  default['gitlab']['redis_unixsocketperms'] = '0770'
else
  default['gitlab']['redis_port'] = '6379'
  default['gitlab']['redis_unixsocketperms'] = nil
end
default['gitlab']['redis_host'] = '127.0.0.1'
default['gitlab']['redis_database'] = nil # Default value is 0
default['gitlab']['namespace'] = 'resque:gitlab'
default['gitlab']['self_signed_cert'] = false

default['gitlab']['redis']['configure'] = true
if node['gitlab']['redis']['configure']
  default['redisio']['servers'] = [{ 'port' => node['gitlab']['redis_port'], 'address' => node['gitlab']['redis_host'] }]
  default['redisio']['default_settings']['unixsocket'] = node['gitlab']['redis_unixsocket']
  default['redisio']['default_settings']['unixsocketperm'] = node['gitlab']['redis_unixsocketperms']
end

# GitLab Web Server Attributes

default['gitlab']['ip'] = '*'
default['gitlab']['install_nginx'] = true
default['gitlab']['ssl_certificate_path'] = '/etc/ssl' # Path to .crt file. If it directory doesn't exist it will be created
default['gitlab']['ssl_certificate_key_path'] = '/etc/ssl' # Path to .key file. If directory doesn't exist it will be created
default['gitlab']['ssl_certificate'] = '' # SSL certificate
default['gitlab']['ssl_certificate_key'] = '' # SSL certificate key
