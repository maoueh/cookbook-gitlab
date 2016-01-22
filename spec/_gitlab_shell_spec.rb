require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_gitlab_shell under #{platform} @ #{version}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: platform, version: version).converge('gitlab::_gitlab_shell')
      end

      it 'clones the gitlab-shell repository' do
        expect(chef_run).to sync_git('/home/git/gitlab-shell').with(
          repository: 'https://github.com/gitlabhq/gitlab-shell.git',
          revision: 'v2.6.8',
          user: 'git',
          group: 'git'
        )
      end

      it 'creates a gitlab shell config' do
        expect(chef_run).to create_template('/home/git/gitlab-shell/config.yml').with(
          source: 'gitlab_shell.yml.erb',
          variables: {
            user: 'git',
            home: '/home/git',
            url: 'http://localhost:80/',
            repos_path: '/home/git/repositories',
            redis_path: '/usr/local/bin/redis-cli',
            redis_host: '127.0.0.1',
            redis_port: '0',
            redis_database: nil,
            redis_unixsocket: '/var/run/redis/sockets/redis.sock',
            namespace: 'resque:gitlab',
            self_signed_cert: false
          }
        )
      end

      it 'creates repository directory in the gitlab user home directory' do
        expect(chef_run).to create_directory('/home/git/repositories').with(
          user: 'git',
          group: 'git',
          mode: 0770
        )
      end

      it 'creates .ssh directory in the gitlab user home directory' do
        expect(chef_run).to create_directory('/home/git/.ssh').with(
          user: 'git',
          group: 'git',
          mode: 0700
        )
      end

      it 'creates authorized hosts file in .ssh directory' do
        expect(chef_run).to create_file_if_missing('/home/git/.ssh/authorized_keys').with(
          user: 'git',
          group: 'git',
          mode: 0600
        )
      end

      it 'does not run a execute to install gitlab shell on its own' do
        expect(chef_run).to_not run_execute('gitlab-shell install')
      end

      describe 'when customizing gitlab user home' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['home'] = '/data/git'
          end.converge('gitlab::_gitlab_shell')
        end

        it 'clones the gitlab-shell repository' do
          expect(chef_run).to sync_git('/data/git/gitlab-shell')
        end

        it 'creates a gitlab shell config' do
          expect(chef_run).to create_template('/data/git/gitlab-shell/config.yml').with(
            source: 'gitlab_shell.yml.erb',
            variables: {
              user: 'git',
              home: '/data/git',
              url: 'http://localhost:80/',
              repos_path: '/data/git/repositories',
              redis_path: '/usr/local/bin/redis-cli',
              redis_host: '127.0.0.1',
              redis_port: '0',
              redis_database: nil,
              redis_unixsocket: '/var/run/redis/sockets/redis.sock',
              namespace: 'resque:gitlab',
              self_signed_cert: false
            }
          )
        end

        it 'creates repository directory in the gitlab user home directory' do
          expect(chef_run).to create_directory('/data/git/repositories')
        end

        it 'creates .ssh directory in the gitlab user home directory' do
          expect(chef_run).to create_directory('/data/git/.ssh')
        end

        it 'creates authorized hosts file in .ssh directory' do
          expect(chef_run).to create_file_if_missing('/data/git/.ssh/authorized_keys')
        end
      end
    end
  end
end
