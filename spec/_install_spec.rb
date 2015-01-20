require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_install under #{platform} @ #{version}" do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: platform, version: version).converge("gitlab::_install")
      end

      it 'enables gitlab service' do
        expect(chef_run).to enable_service('gitlab')
      end

      it 'does not run gitlab service unless subscribed' do
        expect(chef_run).not_to start_service('gitlab')
      end

      it 'creates a gitlab config' do
        expect(chef_run).to create_template('/home/git/gitlab/config/gitlab.yml').with(
          source: 'gitlab.yml.erb',
          variables: {
            host: 'localhost',
            port: '80',
            user: 'git',
            email_enabled: true,
            email_from: 'gitlab@localhost',
            timezone: 'UTC',
            issue_closing_pattern: "([Cc]lose[sd]|[Ff]ixe[sd]) #(\d+)",
            max_size: '20971520',
            git_timeout: 10,
            satellites_path: '/home/git/gitlab-satellites',
            satellites_timeout: 30,
            repos_path: '/home/git/repositories',
            shell_path: '/home/git/gitlab-shell',
            signup_enabled: false,
            signin_enabled: true,
            projects_limit: 10,
            user_can_create_group: true,
            user_can_change_username: true,
            default_theme: 2,
            repository_downloads_path: 'tmp/repositories',
            oauth_enabled: false,
            oauth_block_auto_created_users: true,
            oauth_allow_single_sign_on: false,
            oauth_providers: [],
            google_analytics_id: "",
            sign_in_text: "",
            ssh_port: "22",
            default_projects_features: {
              "issues"=>true,
              "merge_requests"=>true,
              "wiki"=>true,
              "snippets"=>false,
              "visibility_level"=>"private"
              },
            webhook_timeout: 10,
            gravatar: true,
            gravatar_plain_url: "http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon",
            gravatar_ssl_url: "https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon",
            ldap_config: {
              "enabled"=>false,
              "label"=>"LDAP",
              "host"=>"_your_ldap_server",
              "base"=>"_the_base_where_you_search_for_users",
              "port"=>636,
              "uid"=>"sAMAccountName",
              "method"=>"ssl",
              "bind_dn"=>"_the_full_dn_of_the_user_you_will_bind_with",
              "password"=>"_the_password_of_the_bind_user",
              "user_filter"=>"",
              "active_directory"=>true,
              "allow_username_or_email_login"=>true
            },
            backup: {
              "enable"=>true,
              "cron"=>{
                "action"=>:create,
                "minute"=>0,
                "hour"=>2,
                "mailto"=>"gitlab@localhost",
                "path"=>"/usr/local/bin:/usr/bin:/bin"
              },
              "backup_keep_time"=>0,
              "backup_path"=>"tmp/backups"
            }
          }
        )
      end

      it 'triggers updating of git config' do
        template = chef_run.template('/home/git/gitlab/config/gitlab.yml')
        expect(template).to notify('bash[git config]').to(:run).immediately
      end

      it 'updates git config' do
        resource = chef_run.find_resource(:bash, 'git config')
        expect(resource.code).to eq("    git config --global user.name \"GitLab\"\n    git config --global user.email \"gitlab@localhost\"\n    git config --global core.autocrlf input\n")
        expect(resource.user).to eq("git")
        expect(resource.group).to eq("git")
        expect(resource.environment).to eq('HOME' => "/home/git")
      end

      it 'creates required directories in the rails root' do
        %w{log tmp tmp/pids tmp/sockets public/uploads}.each do |path|
          expect(chef_run).to create_directory("/home/git/gitlab/#{path}").with(
            user: 'git',
            group: 'git',
            mode: 0755
          )
        end
      end

      it 'creates satellites directory' do
       expect(chef_run).to create_directory("/home/git/gitlab-satellites").with(
          user: 'git',
          group: 'git'
        )
      end

      it 'creates a unicorn config' do
        expect(chef_run).to create_template('/home/git/gitlab/config/unicorn.rb').with(
          source: 'unicorn.rb.erb',
          variables: {
            app_root: "/home/git/gitlab",
            unicorn_workers_number: 2,
            unicorn_timeout: 60
          }
        )
      end

      it 'creates gitlab init.d script' do
        expect(chef_run).to create_template('/etc/init.d/gitlab').with(
          source: 'gitlab.init.d.erb',
          mode: 0755
        )
      end

      it 'creates gitlab default configuration file' do
        expect(chef_run).to create_template('/etc/default/gitlab').with(
          source: 'gitlab.default.erb',
          mode: 0755,
          variables: {
            app_user: 'git',
            app_root: '/home/git/gitlab'
          }
        )
      end

      it 'creates rack_attack.rb file' do
        expect(chef_run).to create_template('/home/git/gitlab/config/initializers/rack_attack.rb').with(
          source: 'rack_attack.rb.erb',
          mode: 0644
        )
      end

      it 'creates logrotate config' do
        expect(chef_run).to create_template('/etc/logrotate.d/gitlab').with(
          source: 'logrotate.erb',
          mode: 0644,
          variables: {
            gitlab_path: '/home/git/gitlab',
            gitlab_shell_path: '/home/git/gitlab-shell',
          }
        )
      end

      it 'creates a database postgresql config by default' do
        expect(chef_run).to create_template('/home/git/gitlab/config/database.yml').with(
          source: 'database.yml.postgresql.erb',
          user: 'git',
          group: 'git',
          variables: {
            user: 'git',
            password: 'datapass',
            host: "localhost",
            socket: nil
          }
        )
      end

      it 'runs an execute to rake db:schema:load' do
        expect(chef_run).not_to run_execute('rake db:schema:load')
      end

      it 'runs db setup' do
        resource = chef_run.find_resource(:execute, 'rake db:schema:load')
        expect(resource.command).to eq("PATH=#{env_path(chef_run.node)} RAILS_ENV=production bundle exec rake db:schema:load")
        expect(resource.user).to eq("git")
        expect(resource.group).to eq("git")
        expect(resource.cwd).to eq("/home/git/gitlab")
      end

      it 'runs an execute to rake db:migrate' do
        expect(chef_run).not_to run_execute('rake db:migrate')
      end

      it 'runs db migrate' do
        resource = chef_run.find_resource(:execute, 'rake db:migrate')
        expect(resource.command).to eq("PATH=#{env_path(chef_run.node)} RAILS_ENV=production bundle exec rake db:migrate")
        expect(resource.user).to eq("git")
        expect(resource.group).to eq("git")
        expect(resource.cwd).to eq("/home/git/gitlab")
      end

      it 'runs an execute to rake db:seed' do
        expect(chef_run).not_to run_execute('rake db:seed_fu')
      end

      it 'runs db seed' do
        resource = chef_run.find_resource(:execute, 'rake db:seed_fu')
        expect(resource.command).to eq("PATH=#{env_path(chef_run.node)} RAILS_ENV=production bundle exec rake db:seed_fu")
        expect(resource.user).to eq("git")
        expect(resource.group).to eq("git")
        expect(resource.cwd).to eq("/home/git/gitlab")
        expect(resource.environment).to eq("GITLAB_ROOT_PASSWORD" => nil)
      end

      describe "when using mysql" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['database_adapter'] = "mysql"
          end.converge("gitlab::_install")
        end

        it 'creates a database mysql config' do
          expect(chef_run).to create_template('/home/git/gitlab/config/database.yml').with(
            source: 'database.yml.mysql.erb',
            user: 'git',
            group: 'git',
            variables: {
              user: 'git',
              password: 'datapass',
              host: "127.0.0.1",
              socket: nil,
            }
          )
        end
      end

      describe "when using mysql with custom server socket" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['database_adapter'] = "mysql"
            node.set['mysql']['server']['socket'] = "/tmp/mysql.sock"
          end.converge("gitlab::_install")
        end

        it 'creates a database mysql config connecting through socket' do
          expect(chef_run).to create_template('/home/git/gitlab/config/database.yml').with(
            source: 'database.yml.mysql.erb',
            user: 'git',
            group: 'git',
            variables: {
              user: 'git',
              password: 'datapass',
              host: "127.0.0.1",
              socket: "/tmp/mysql.sock"
            }
          )
        end
      end

      describe "when supplying root password" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['admin_root_password'] = "NEWPASSWORD"
          end.converge("gitlab::_install")
        end

        it 'runs db seed' do
          resource = chef_run.find_resource(:execute, 'rake db:seed_fu')
          expect(resource.command).to eq("PATH=#{env_path(chef_run.node)} RAILS_ENV=production bundle exec rake db:seed_fu")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
          expect(resource.environment).to eq("GITLAB_ROOT_PASSWORD" => "NEWPASSWORD")
        end
      end

      describe "when customizing gitlab user home" do
        # Only test stuff that change when git user home is different
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['home'] = "/data/git"
          end.converge("gitlab::_install")
        end

        it 'creates a gitlab config' do
          expect(chef_run).to create_template('/data/git/gitlab/config/database.yml')
        end

        it 'updates git config' do
          resource = chef_run.find_resource(:bash, 'git config')
          expect(resource.environment).to eq('HOME' =>"/data/git")
        end

        it 'creates required directories in the rails root' do
          %w{log tmp tmp/pids tmp/sockets public/uploads}.each do |path|
            expect(chef_run).to create_directory("/data/git/gitlab/#{path}").with(
              user: 'git',
              group: 'git',
              mode: 0755
            )
          end
        end

        it 'creates satellites directory' do
         expect(chef_run).to create_directory("/data/git/gitlab-satellites")
        end

        it 'creates a unicorn config' do
          expect(chef_run).to create_template('/data/git/gitlab/config/unicorn.rb')
        end

        it 'creates gitlab default configuration file' do
          expect(chef_run).to create_template('/etc/default/gitlab').with(
            variables: {
              app_user: 'git',
              app_root: '/data/git/gitlab'
            }
          )
        end

        it 'creates logrotate config' do
          expect(chef_run).to create_template('/etc/logrotate.d/gitlab').with(
            variables: {
              gitlab_path: '/data/git/gitlab',
              gitlab_shell_path: '/data/git/gitlab-shell',
            }
          )
        end

        it 'creates a database config' do
          expect(chef_run).to create_template('/data/git/gitlab/config/database.yml')
        end

        it 'runs db setup' do
          resource = chef_run.find_resource(:execute, 'rake db:schema:load')
          expect(resource.cwd).to eq("/data/git/gitlab")
        end

        it 'runs db migrate' do
          resource = chef_run.find_resource(:execute, 'rake db:migrate')
          expect(resource.cwd).to eq("/data/git/gitlab")
        end

        it 'runs db seed' do
          resource = chef_run.find_resource(:execute, 'rake db:seed_fu')
          expect(resource.cwd).to eq("/data/git/gitlab")
        end
      end
    end
  end
end
