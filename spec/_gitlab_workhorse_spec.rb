require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_gitlab_workhorse under #{platform} @ #{version}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: platform, version: version).converge('gitlab::_gitlab_workhorse')
      end

      it 'clones the gitlab-workhorse repository' do
        expect(chef_run).to sync_git('/home/git/gitlab-workhorse').with(
          repository: 'https://gitlab.com/gitlab-org/gitlab-workhorse.git',
          revision: '0.7.2',
          user: 'git',
          group: 'git'
        )
      end

      it 'install gitlab-workhorse correctly' do
        resource = chef_run.bash('install gitlab-workhorse 0.7.2')

        expect(chef_run).to run_bash('install gitlab-workhorse 0.7.2')
        expect(resource.code).to match(%r{cd /home/git/gitlab-workhorse})
        expect(resource.code).to match(/make/)
      end

      describe 'when customizing gitlab user home' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['home'] = '/data/git'
          end.converge('gitlab::_gitlab_workhorse')
        end

        it 'install gitlab-workhorse correctly' do
          resource = chef_run.bash('install gitlab-workhorse 0.7.2')

          expect(resource.code).to match(%r{cd /data/git/gitlab-workhorse})
        end
      end
    end
  end
end
