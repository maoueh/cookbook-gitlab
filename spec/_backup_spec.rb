# -*- mode: ruby; coding: utf-8; -*-
require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_backup under #{platform} @ #{version}" do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: platform, version: version).converge("gitlab::_backup")
      end

      it "creates a cron" do
        expect(chef_run).to create_cron('gitlab_backups').with(
          minute: '0',
          hour: '2',
          user: 'git',
          mailto: 'gitlab@localhost',
          path: '/usr/local/bin:/usr/bin:/bin')
      end

      describe "when backup disabled" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['backup']['enable'] = false
          end.converge("gitlab::_backup")
        end

        it "does not create a cron job" do
          expect(chef_run).to_not create_cron('gitlab_backups')
        end
      end
    end
  end
end
