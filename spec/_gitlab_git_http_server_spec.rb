require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_gitlab_git_http_server under #{platform} @ #{version}" do
      cached(:chef_run) do
         ChefSpec::SoloRunner.new(platform: platform, version: version).converge('gitlab::_gitlab_git_http_server')
      end

      it 'clones the gitlab-git-http-server repository' do
        expect(chef_run).to sync_git('/home/git/gitlab-git-http-server').with(
          repository: 'https://gitlab.com/gitlab-org/gitlab-git-http-server.git',
          revision: '0.2.14',
          user: 'git',
          group: 'git'
        )
      end

      it 'install gitlab-git-http-server correctly' do
        resource = chef_run.bash('install gitlab-git-http-server 0.2.14')

        expect(chef_run).to run_bash('install gitlab-git-http-server 0.2.14')
        expect(resource.code).to match(%r{cd /home/git/gitlab-git-http-server})
        expect(resource.code).to match(/make/)
      end

      describe 'when customizing gitlab user home' do
        cached(:chef_run) do
           ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['home'] = '/data/git'
          end.converge('gitlab::_gitlab_git_http_server')
        end

        it 'install gitlab-git-http-server correctly' do
          resource = chef_run.bash('install gitlab-git-http-server 0.2.14')

          expect(resource.code).to match(%r{cd /data/git/gitlab-git-http-server})
        end
      end
    end
  end
end
