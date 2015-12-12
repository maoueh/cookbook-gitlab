require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_users under #{platform} @ #{version}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: platform, version: version).converge('gitlab::_users')
      end

      it 'creates a user that will run gitlab' do
        expect(chef_run).to create_user('git')
      end

      it 'locks a created user' do
        expect(chef_run).to lock_user('git')
      end
    end
  end
end
