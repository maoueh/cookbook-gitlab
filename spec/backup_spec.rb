# -*- mode: ruby; coding: utf-8; -*-
require 'spec_helper'

describe "gitlab::backup" do
  let(:chef_run) { ChefSpec::Runner.new.converge("gitlab::backup") }


  describe "under ubuntu" do
    ["14.04", "12.04", "10.04"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::backup")
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
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['backup']['enable'] = false
          runner.converge("gitlab::backup")
        end

        it "does not create a cron job" do
          expect(chef_run).to_not create_cron('gitlab_backups')
        end
      end

      describe "when in development environment" do
        let(:chef_run) do
          runner = ChefSpec::Runner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::backup")
        end

        it "do not create a cron" do
          expect(chef_run).to_not create_cron('gitlab_backups')
        end
      end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::Runner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::backup")
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
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['backup']['enable'] = false
          runner.converge("gitlab::backup")
        end

        it "does not create a cron job" do
          expect(chef_run).to_not create_cron('gitlab_backups')
        end
      end

      describe "when in development environment" do
        let(:chef_run) do
          runner = ChefSpec::Runner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::backup")
        end

        it "do not create a cron" do
          expect(chef_run).to_not create_cron('gitlab_backups')
        end
      end
    end
  end
end
