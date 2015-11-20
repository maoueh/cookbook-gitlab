require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_clone under #{platform} @ #{version}" do
      cached(:chef_run) do
         ChefSpec::SoloRunner.new(platform: platform, version: version).converge('gitlab::_clone')
      end

      it 'clones the gitlab repository' do
        expect(chef_run).to sync_git('/home/git/gitlab').with(
          repository: 'https://github.com/gitlabhq/gitlabhq.git',
          revision: '8-1-stable',
          user: 'git',
          group: 'git'
        )
      end

      describe 'when customizing gitlab user home' do
        cached(:chef_run) do
           ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['home'] = '/data/git'
          end.converge('gitlab::_clone')
        end

        it 'clones the gitlab repository' do
          expect(chef_run).to sync_git('/data/git/gitlab')
        end
      end
    end
  end
end
