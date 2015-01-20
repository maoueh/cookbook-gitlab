# Packages
if platform_family?("rhel")
  packages = %w{
    libicu-devel libxslt-devel libyaml-devel libxml2-devel gdbm-devel libffi-devel zlib-devel openssl-devel
    libyaml-devel readline-devel curl-devel openssl-devel pcre-devel mysql-devel gcc-c++
    ImageMagick-devel ImageMagick cmake
  }
else
  packages = %w{
    build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev
    curl openssh-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev python-docutils
    logrotate vim curl wget checkinstall cmake
  }
end

default['gitlab']['packages'] = packages
default['gitlab']['compile_ruby'] = true
default['gitlab']['ruby'] = "2.1.2"

# User
default['gitlab']['user'] = "git"
default['gitlab']['group'] = "git"
default['gitlab']['user_uid'] = nil # Use to specify user id.
default['gitlab']['user_gid'] = nil # Use to specify group id.
default['gitlab']['home'] = "/home/git"

# GitLab hq
default['gitlab']['path'] = "#{node['gitlab']['home']}/gitlab"
default['gitlab']['satellites_path'] = "#{node['gitlab']['home']}/gitlab-satellites"
default['gitlab']['satellites_timeout'] = 30

# GitLab shell
default['gitlab']['shell_repository'] = "https://github.com/gitlabhq/gitlab-shell.git"
default['gitlab']['shell_path'] = "#{node['gitlab']['home']}/gitlab-shell"
default['gitlab']['shell_revision'] = "v2.4.0"

# GitLab shell configuration
include_attribute 'redisio'

default['gitlab']['repos_path'] = "#{node['gitlab']['home']}/repositories"
default['gitlab']['redis_path'] = "/usr/local/bin/redis-cli"
default['gitlab']['redis_socket_directory'] = "#{default['redisio']['base_piddir']}/sockets"
default['gitlab']['redis_unixsocket'] = "#{default['gitlab']['redis_socket_directory']}/redis.sock" # To disable redis using Unix sockets set this value to nil
if node['gitlab']['redis_unixsocket']
  default['gitlab']['redis_port'] = "0"
  default['gitlab']['redis_unixsocketperms'] = "0770"
else
  default['gitlab']['redis_port'] = "6379"
  default['gitlab']['redis_unixsocketperms'] = nil
end
default['gitlab']['redis_host'] = "127.0.0.1"
default['gitlab']['redis_database'] = nil # Default value is 0
default['gitlab']['namespace']  = "resque:gitlab"
default['gitlab']['self_signed_cert'] = false

# Redis
default['gitlab']['redis']['configure'] = true
if node['gitlab']['redis']['configure']
  default['redisio']['servers'] = [{'port' => node['gitlab']['redis_port'], 'address' => node['gitlab']['redis_host']}]
  default['redisio']['default_settings']['unixsocket'] = node['gitlab']['redis_unixsocket']
  default['redisio']['default_settings']['unixsocketperm'] = node['gitlab']['redis_unixsocketperms']
end

# GitLab
default['gitlab']['repository'] = "https://github.com/gitlabhq/gitlabhq.git"
default['gitlab']['deploy_key'] = "" # Optional. Private key used to connect to private GitLab repository.

# Setup environments

default['gitlab']['environments'] = %w{production}
default['gitlab']['revision'] = "7-6-stable" # Must be branch, otherwise GitLab update will run on each chef run
default['gitlab']['url'] = "http://localhost:80/"
default['gitlab']['port'] = "80"
default['gitlab']['ssh_port'] = "22"

# Nginx ip
default['gitlab']['ip'] = "*"

# GitLab configuration
default['gitlab']['git_path'] = "/usr/local/bin/git"
default['gitlab']['host'] = "localhost"
default['gitlab']['email_enabled'] = true
default['gitlab']['email_from'] = "gitlab@localhost"

default['gitlab']['timezone'] = "UTC"
default['gitlab']['issue_closing_pattern'] = "([Cc]lose[sd]|[Ff]ixe[sd]) #(\d+)"
default['gitlab']['max_size'] = "20971520" # 20.megabytes
default['gitlab']['git_timeout'] = 10
default['gitlab']['signup_enabled'] = false
default['gitlab']['signin_enabled'] = true
default['gitlab']['projects_limit'] = 10
default['gitlab']['user_can_create_group'] = true
default['gitlab']['user_can_change_username'] = true
default['gitlab']['default_theme'] = 2
default['gitlab']['repository_downloads_path'] = "tmp/repositories"
default['gitlab']['oauth_enabled'] = false
default['gitlab']['oauth_block_auto_created_users'] = true
default['gitlab']['oauth_allow_single_sign_on'] = false
default['gitlab']['oauth_providers'] = [] # Example: default['gitlab']['oauth_providers'] = [ { "name": "google_oauth2", "app_id": "YOUR APP ID", "app_secret": "YOUR APP SECRET", "args": "access_type: 'offline', approval_prompt: ''" }, { "name": "twitter", "app_id": "YOUR APP ID", "app_secret": "YOUR APP SECRET" }, { "name":"github", "app_id": "YOUR APP ID", "app_secret": "YOUR APP SECRET" }]

default['gitlab']['extra']['google_analytics_id'] = "" # Example:  "AA-1231231-1"
default['gitlab']['extra']['sign_in_text'] = "" # Example:  "![Company Logo](http://www.example.com/logo.png)"

default['gitlab']['ldap']['enabled'] = false
default['gitlab']['ldap']['label'] = "LDAP"
default['gitlab']['ldap']['host'] = "_your_ldap_server"
default['gitlab']['ldap']['base'] = "_the_base_where_you_search_for_users"
default['gitlab']['ldap']['port'] = 636
default['gitlab']['ldap']['uid'] = "sAMAccountName"
default['gitlab']['ldap']['method'] = "ssl"
default['gitlab']['ldap']['bind_dn'] = "_the_full_dn_of_the_user_you_will_bind_with"
default['gitlab']['ldap']['password'] = "_the_password_of_the_bind_user"
default['gitlab']['ldap']['allow_username_or_email_login'] = true
default['gitlab']['ldap']['active_directory'] = true
default['gitlab']['ldap']['allow_username_or_email_login'] = true

# LDAP Filter Example: Recursive query of group membership
# default['gitlab']['ldap']['user_filter'] = '(&(objectcategory=person)(objectclass=user)(memberOf:1.2.840.113556.1.4.1941:=CN=Gitlab Users,OU=USA,DC=int,DC=contoso,DC=com))'
default['gitlab']['ldap']['user_filter'] = ''

default['gitlab']['gravatar'] = true
default['gitlab']['gravatar_plain_url'] = "http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon"
default['gitlab']['gravatar_ssl_url'] = "https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon"

default['gitlab']['default_projects_features']['issues'] = true
default['gitlab']['default_projects_features']['merge_requests'] = true
default['gitlab']['default_projects_features']['wiki'] = true
default['gitlab']['default_projects_features']['snippets'] = false
default['gitlab']['default_projects_features']['visibility_level'] = "private"

default['gitlab']['webhook_timeout'] = 10

# Default admin user password
default['gitlab']['admin_root_password'] = nil

# Databases
# Assumed defaults
# database: postgresql (option: mysql)
# environment: production (option: development)
default['gitlab']['external_database'] = false
default['gitlab']['database_adapter'] = "postgresql"
default['gitlab']['database_password'] = "datapass"
default['gitlab']['database_user'] = "git"
default['gitlab']['database_allowed_host'] = "localhost" # Used by MySQL only

# SELinux attributes
default['selinux']['state'] = "disabled"

# Ruby build attributes
override['ruby_build']['install_git_pkgs'] = []

# Git attributes
default['git']['prefix'] = '/usr/local'
default['git']['version'] = '2.1.4'
default['git']['url'] = "https://github.com/git/git/archive/v#{node['git']['version']}.tar.gz"
default['git']['checksum'] = '87ee4f10a64646daeaa4fed38da8afd48d60af18da51b59b6beea05345b06764'

# MySQL attributes (server)
default['mysql']['server']['instance'] = "gitlab"
default['mysql']['server']['host'] = "127.0.0.1"
default['mysql']['server']['data_dir'] = nil
default['mysql']['server']['charset'] = "utf8"
default['mysql']['server']['port'] = "3306"
default['mysql']['server']['socket'] = nil
default['mysql']['server']['version'] = "5.5"
default['mysql']['server']['username'] = "root"
default['mysql']['server']['password'] = "rootpass"

# PostgreSQL attributes
include_attribute 'postgresql'

default['postgresql']['version'] = "9.3"
case node["platform_family"]
when "debian"
  default['postgresql']['enable_pgdg_apt'] = true
  default['postgresql']['client']['packages'] = %w{postgresql-client-9.3 libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql-9.3}
  # due to the way attributes are organized we have to override the default paths too
  default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['config']['data_directory'] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
  default['postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
  default['postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
  default['postgresql']['config']['ssl'] = false
  default['postgresql']['config']['unix_socket_directory'] = nil
  default['postgresql']['config']['unix_socket_directories'] = '/var/run/postgresql'
  default['gitlab']['postgresql']['configuration_dir'] = nil
when "rhel"
  default['postgresql']['enable_pgdg_yum'] = true
  default['postgresql']['client']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-devel"]
  default['postgresql']['server']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-server"]
  default['postgresql']['contrib']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-contrib"]
  default['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
  default['gitlab']['postgresql']['configuration_dir'] = "/usr/pgsql-#{node['postgresql']['version']}/bin"
end
default['postgresql']['username']['postgres'] = "postgres"
default['postgresql']['password']['postgres'] = "psqlpass"
default['postgresql']['server']['host'] = "localhost"

# Postfix
default['postfix']['mail_type'] = "client"
default['postfix']['myhostname'] = "mail.localhost"
default['postfix']['mydomain'] = "localhost"
default['postfix']['myorigin'] = "mail.localhost"
default['postfix']['smtp_use_tls'] = "no"

# Unicorn specific configuration
default['gitlab']['unicorn_workers_number'] = 2
default['gitlab']['unicorn_timeout'] = 60

# Nginx & Nginx ssl certificates
default['gitlab']['install_nginx'] = true
default['gitlab']['ssl_certificate_path'] = "/etc/ssl" # Path to .crt file. If it directory doesn't exist it will be created
default['gitlab']['ssl_certificate_key_path'] = "/etc/ssl" # Path to .key file. If directory doesn't exist it will be created
default['gitlab']['ssl_certificate'] = "" # SSL certificate
default['gitlab']['ssl_certificate_key'] = "" # SSL certificate key
default['gitlab']['client_max_body_size'] = "20m"

# SMTP email
default['gitlab']['smtp'] = {
  :enabled => false,
  :address => "email.server.com",
  :port => 456,
  :username => "smtp",
  :password => "123456",
  :domain => "gitlab.example.com",
  :authentication => "login",
  :enable_starttls_auto => true
}

# backups
default['gitlab']['backup']['enable'] = true
default['gitlab']['backup']['cron']['action'] = :create
default['gitlab']['backup']['cron']['minute'] = 0
default['gitlab']['backup']['cron']['hour'] = 2
default['gitlab']['backup']['cron']['mailto'] = 'gitlab@localhost'
default['gitlab']['backup']['cron']['path'] = '/usr/local/bin:/usr/bin:/bin'
default['gitlab']['backup']['backup_keep_time'] = 0
default['gitlab']['backup']['backup_path'] = 'tmp/backups'
