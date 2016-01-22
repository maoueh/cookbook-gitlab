require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_install under #{platform} @ #{version}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: platform, version: version).converge('gitlab::_install')
      end

      it 'creates required directories in the rails root' do
        %w(log tmp tmp/pids tmp/sockets public/uploads).each do |path|
          expect(chef_run).to create_directory("/home/git/gitlab/#{path}").with(
            user: 'git',
            group: 'git',
            mode: 0755
          )
        end
      end

      it 'creates satellites directory' do
        expect(chef_run).to create_directory('/home/git/gitlab-satellites').with(
          user: 'git',
          group: 'git'
        )
      end

      it 'creates a gitlab config' do
        expect(chef_run).to create_template('/home/git/gitlab/config/gitlab.yml').with(
          source: 'gitlab.yml.erb',
          variables: {
            'host' => 'localhost',
            'port' => '80',
            'user' => 'git',
            'email_enabled' => true,
            'email_display_name' => 'GitLab',
            'email_from' => 'gitlab@localhost',
            'email_reply_to' => 'noreply@localhost',
            'timezone' => 'UTC',
            'issue_closing_pattern' => '((?:[Cc]los(?:e[sd]?|ing)|[Ff]ix(?:e[sd]|ing)?) +(?:(?:issues? +)?%{issue_ref}(?:(?:, *| +and +)?))+)',
            'max_size' => '20971520',
            'git_timeout' => 10,
            'git_bin_path' => '/usr/local/bin/git',
            'satellites_path' => '/home/git/gitlab-satellites',
            'repos_path' => '/home/git/repositories',
            'shell_path' => '/home/git/gitlab-shell',
            'shell_secret_file' => '/home/git/gitlab/.gitlab_shell_secret',
            'user_can_create_group' => true,
            'user_can_change_username' => true,
            'default_theme' => 2,
            'repository_downloads_path' => 'tmp/repositories',
            'ssh_port' => '22',
            'webhook_timeout' => 10,

            # Nested configurations
            'backup' => {
              'enable' => true,
              'cron' => {
                'action' => :create,
                'minute' => 0,
                'hour' => 2,
                'mailto' => 'gitlab@localhost',
                'path' => '/usr/local/bin:/usr/bin:/bin'
              },
              'backup_keep_time' => 0,
              'backup_path' => 'tmp/backups',
              'archive_permissions' => '0640',
              'pg_schema' => nil
            },
            'build_artifacts' => {
              'enabled' => true,
              'path' => 'shared/artifacts'
            },
            'ci' => {
              'all_broken_builds' => true,
              'add_pusher' => true,
              'builds_path' => 'builds/'
            },
            'cron_jobs' => {
              'stuck_ci_builds_worker' => {
                'cron' => '0 0 * * *'
              }
            },
            'extra' => {
              'google_analytics_id' => ''
            },
            'features' => {
              'issues' => true,
              'merge_requests' => true,
              'wiki' => true,
              'snippets' => false,
              'builds' => true
            },
            'gravatar' => {
              'enabled' => true,
              'plain_url' => 'http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon',
              'ssl_url' => 'https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon'
            },
            'ldap' => {
              'enabled' => false,
              'label' => 'LDAP',
              'host' => '_your_ldap_server',
              'base' => '_the_base_where_you_search_for_users',
              'port' => 389,
              'uid' => 'sAMAccountName',
              'method' => 'plain',
              'bind_dn' => '_the_full_dn_of_the_user_you_will_bind_with',
              'password' => '_the_password_of_the_bind_user',
              'user_filter' => '',
              'active_directory' => true,
              'allow_username_or_email_login' => true,
              'block_auto_created_users' => false,
              'timeout' => 10,
              'attributes' => {
                'username' => "['uid', 'userid', 'sAMAccountName']",
                'email' => "['mail', 'email', 'userPrincipalName']",
                'name' => 'cn',
                'first_name' => 'givenName',
                'last_name' => 'sn'
              }
            },
            'lfs' => {
              'enabled' => true,
              'path' => 'shared/lfs-objects'
            },
            'oauth' => {
              'enabled' => false,
              'block_auto_created_users' => true,
              'auto_link_ldap_user' => false,
              'allow_single_sign_on' => false,
              'providers' => []
            },
            'reply_by_email' => {
              'enabled' => false,
              'address' => 'gitlab-incoming+%{key}@gmail.com',
              'user' => 'gitlab-incoming@gmail.com',
              'password' => '[REDACTED]',
              'host' => 'imap.gmail.com',
              'port' => 993,
              'ssl' => true,
              'start_tls' => false,
              'mailbox' => 'inbox'
            },
            'shared' => {
              'path' => '/mnt/gitlab'
            }
          }
        )
      end

      it 'triggers updating of git config' do
        template = chef_run.template('/home/git/gitlab/config/gitlab.yml')
        expect(template).to notify('bash[git config]').to(:run).immediately
      end

      it 'creates a gitlab secrets config' do
        expect(chef_run).to create_template('/home/git/gitlab/config/secrets.yml').with(
          user: 'git',
          group: 'git',
          mode: 0600,
          source: 'secrets.yml.erb',
          variables: {
            'secret_key' => 'not_random_change_me_now_with_random_30_characters_no_words'
          }
        )
      end

      it 'updates git config' do
        resource = chef_run.find_resource(:bash, 'git config')
        expect(resource.code).to eq("    git config --global user.name \"GitLab\"\n    git config --global user.email \"gitlab@localhost\"\n    git config --global core.autocrlf input\n")
        expect(resource.user).to eq('git')
        expect(resource.group).to eq('git')
        expect(resource.environment).to eq('HOME' => '/home/git')
      end

      it 'creates a unicorn config' do
        expect(chef_run).to create_template('/home/git/gitlab/config/unicorn.rb').with(
          source: 'unicorn.rb.erb',
          variables: {
            'app_root' => '/home/git/gitlab',
            'unicorn_workers_number' => 3,
            'unicorn_timeout' => 60
          }
        )
      end

      it 'creates rack_attack.rb file' do
        expect(chef_run).to create_template('/home/git/gitlab/config/initializers/rack_attack.rb').with(
          source: 'rack_attack.rb.erb',
          mode: 0644
        )
      end

      it 'creates a database postgresql config by default' do
        expect(chef_run).to create_template('/home/git/gitlab/config/database.yml').with(
          source: 'database.yml.postgresql.erb',
          user: 'git',
          group: 'git',
          variables: {
            'user' => 'git',
            'password' => 'datapass',
            'host' => 'localhost',
            'socket' => nil
          }
        )
      end

      it 'executes bundle install with correct arguments' do
        resource = chef_run.find_resource(:execute, 'bundle install')

        expect(resource.command).to eq("SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem PATH=#{env_path(chef_run.node)} bundle install --path=.bundle --deployment --without development test mysql")
        expect(resource.user).to eq('git')
        expect(resource.group).to eq('git')
        expect(resource.cwd).to eq('/home/git/gitlab')
      end

      it 'runs an execute to rake db:setup' do
        expect(chef_run).not_to run_execute('rake db:setup')
      end

      it 'runs db setup' do
        resource = chef_run.find_resource(:execute, 'rake db:setup')
        expect(resource.command).to eq("PATH=#{env_path(chef_run.node)} RAILS_ENV=production bundle exec rake db:setup")
        expect(resource.user).to eq('git')
        expect(resource.group).to eq('git')
        expect(resource.cwd).to eq('/home/git/gitlab')
      end

      it 'runs an execute to rake db:migrate' do
        expect(chef_run).not_to run_execute('rake db:migrate')
      end

      it 'runs db migrate' do
        resource = chef_run.find_resource(:execute, 'rake db:migrate')
        expect(resource.command).to eq("PATH=#{env_path(chef_run.node)} RAILS_ENV=production bundle exec rake db:migrate")
        expect(resource.user).to eq('git')
        expect(resource.group).to eq('git')
        expect(resource.cwd).to eq('/home/git/gitlab')
      end

      it 'runs an execute to rake db:seed' do
        expect(chef_run).not_to run_execute('rake db:seed_fu')
      end

      it 'runs db seed' do
        resource = chef_run.find_resource(:execute, 'rake db:seed_fu')
        expect(resource.command).to eq("PATH=#{env_path(chef_run.node)} RAILS_ENV=production bundle exec rake db:seed_fu")
        expect(resource.user).to eq('git')
        expect(resource.group).to eq('git')
        expect(resource.cwd).to eq('/home/git/gitlab')
        expect(resource.environment).to eq('GITLAB_ROOT_PASSWORD' => nil)
      end

      it 'creates logrotate config' do
        expect(chef_run).to create_template('/etc/logrotate.d/gitlab').with(
          source: 'logrotate.erb',
          mode: 0644,
          variables: {
            'gitlab_path' => '/home/git/gitlab',
            'gitlab_shell_path' => '/home/git/gitlab-shell'
          }
        )
      end

      it 'creates gitlab init.d script' do
        case
        when platform == 'centos'
          services = ['redis0', 'postgresql-9.3']
        when platform == 'ubuntu'
          services = ['redis0', 'postgresql']
        end

        expect(chef_run).to create_template('/etc/init.d/gitlab').with(
          source: 'gitlab.init.d.erb',
          mode: 0755,
          variables: {
            'required_services' => services
          }
        )

        expect(chef_run).to render_file('/etc/init.d/gitlab').with_content('# Required-Start:    $local_fs $remote_fs $network $syslog redis0 postgresql')
      end

      it 'creates gitlab default configuration file' do
        expect(chef_run).to create_template('/etc/default/gitlab').with(
          source: 'gitlab.default.erb',
          mode: 0755,
          variables: {
            'app_user' => 'git',
            'app_root' => '/home/git/gitlab',
            'mail_room' => {
              'enabled' => false
            },
            'shell_path' => '/bin/bash'
          }
        )
      end

      it 'enables gitlab service' do
        expect(chef_run).to enable_service('gitlab')
      end

      it 'starts gitlab service' do
        expect(chef_run).to start_service('gitlab')
      end

      describe 'when using mysql' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['database_adapter'] = 'mysql'
          end.converge('gitlab::_install')
        end

        it 'creates a database mysql config' do
          expect(chef_run).to create_template('/home/git/gitlab/config/database.yml').with(
            source: 'database.yml.mysql.erb',
            user: 'git',
            group: 'git',
            variables: {
              'user' => 'git',
              'password' => 'datapass',
              'host' => '127.0.0.1',
              'socket' => nil
            }
          )
        end

        it 'executes bundle install with correct arguments' do
          resource = chef_run.find_resource(:execute, 'bundle install')

          expect(resource.command).to eq("SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem PATH=#{env_path(chef_run.node)} bundle install --path=.bundle --deployment --without development test postgres")
          expect(resource.user).to eq('git')
          expect(resource.group).to eq('git')
          expect(resource.cwd).to eq('/home/git/gitlab')
        end

        it 'creates gitlab init.d script' do
          expect(chef_run).to create_template('/etc/init.d/gitlab').with(
            variables: {
              'required_services' => ['redis0', 'mysql-gitlab']
            }
          )

          expect(chef_run).to render_file('/etc/init.d/gitlab').with_content('# Required-Start:    $local_fs $remote_fs $network $syslog redis0 mysql-gitlab')
        end
      end

      describe 'when using mysql with custom server socket' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['database_adapter'] = 'mysql'
            node.set['mysql']['server']['socket'] = '/tmp/mysql.sock'
          end.converge('gitlab::_install')
        end

        it 'creates a database mysql config connecting through socket' do
          expect(chef_run).to create_template('/home/git/gitlab/config/database.yml').with(
            source: 'database.yml.mysql.erb',
            user: 'git',
            group: 'git',
            variables: {
              'user' => 'git',
              'password' => 'datapass',
              'host' => '127.0.0.1',
              'socket' => '/tmp/mysql.sock'
            }
          )
        end
      end

      describe 'when supplying root password' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['admin_root_password'] = 'NEWPASSWORD'
          end.converge('gitlab::_install')
        end

        it 'runs db seed' do
          resource = chef_run.find_resource(:execute, 'rake db:seed_fu')
          expect(resource.command).to eq("PATH=#{env_path(chef_run.node)} RAILS_ENV=production bundle exec rake db:seed_fu")
          expect(resource.user).to eq('git')
          expect(resource.group).to eq('git')
          expect(resource.cwd).to eq('/home/git/gitlab')
          expect(resource.environment).to eq('GITLAB_ROOT_PASSWORD' => 'NEWPASSWORD')
        end
      end

      describe 'when customizing gitlab user home' do
        # Only test stuff that change when git user home is different
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['home'] = '/data/git'
          end.converge('gitlab::_install')
        end

        it 'creates required directories in the rails root' do
          %w(log tmp tmp/pids tmp/sockets public/uploads).each do |path|
            expect(chef_run).to create_directory("/data/git/gitlab/#{path}").with(
              user: 'git',
              group: 'git',
              mode: 0755
            )
          end
        end

        it 'creates satellites directory' do
          expect(chef_run).to create_directory('/data/git/gitlab-satellites')
        end

        it 'creates a gitlab config' do
          resource = chef_run.find_resource(:template, '/data/git/gitlab/config/gitlab.yml')

          expect(resource.variables['satellites_path']).to eq('/data/git/gitlab-satellites')
          expect(resource.variables['repos_path']).to eq('/data/git/repositories')
          expect(resource.variables['shell_path']).to eq('/data/git/gitlab-shell')
          expect(resource.variables['shell_secret_file']).to eq('/data/git/gitlab/.gitlab_shell_secret')
        end

        it 'creates a gitlab secrets config' do
          expect(chef_run).to create_template('/data/git/gitlab/config/secrets.yml')
        end

        it 'creates a gitlab database config' do
          expect(chef_run).to create_template('/data/git/gitlab/config/database.yml')
        end

        it 'updates git config' do
          resource = chef_run.find_resource(:bash, 'git config')
          expect(resource.environment).to eq('HOME' => '/data/git')
        end

        it 'creates a unicorn config' do
          expect(chef_run).to create_template('/data/git/gitlab/config/unicorn.rb')
        end

        it 'creates gitlab default configuration file' do
          expect(chef_run).to create_template('/etc/default/gitlab').with(
            variables: {
              'app_user' => 'git',
              'app_root' => '/data/git/gitlab',
              'mail_room' => {
                'enabled' => false
              },
              'shell_path' => '/bin/bash'
            }
          )
        end

        it 'creates a database config' do
          expect(chef_run).to create_template('/data/git/gitlab/config/database.yml')
        end

        it 'creates logrotate config' do
          expect(chef_run).to create_template('/etc/logrotate.d/gitlab').with(
            variables: {
              'gitlab_path' => '/data/git/gitlab',
              'gitlab_shell_path' => '/data/git/gitlab-shell'
            }
          )
        end

        it 'executes bundle install in customized working directory' do
          resource = chef_run.find_resource(:execute, 'bundle install')

          expect(resource.cwd).to eq('/data/git/gitlab')
        end

        it 'runs db setup' do
          resource = chef_run.find_resource(:execute, 'rake db:setup')
          expect(resource.cwd).to eq('/data/git/gitlab')
        end

        it 'runs db migrate' do
          resource = chef_run.find_resource(:execute, 'rake db:migrate')
          expect(resource.cwd).to eq('/data/git/gitlab')
        end

        it 'runs db seed' do
          resource = chef_run.find_resource(:execute, 'rake db:seed_fu')
          expect(resource.cwd).to eq('/data/git/gitlab')
        end
      end
    end
  end
end
