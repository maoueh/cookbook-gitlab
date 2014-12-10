require 'spec_helper'

describe "gitlab::clone" do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge("gitlab::clone", "gitlab::start") }


  describe "under ubuntu" do
    ["14.04", "12.04"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::clone", "gitlab::start")
      end

      it "clones the gitlab repository" do
        expect(chef_run).to sync_git('/home/git/gitlab').with(
          repository: 'https://github.com/gitlabhq/gitlabhq.git',
          revision: '7-5-stable',
          user: 'git',
          group: 'git'
        )
      end

      describe "in development" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::clone", "gitlab::start")
        end

        it "clones the gitlab repository" do
          expect(chef_run).to sync_git('/home/git/gitlab').with(
            repository: 'https://github.com/gitlabhq/gitlabhq.git',
            revision: 'master',
            user: 'git',
            group: 'git'
          )
        end
      end

      describe "when customizing gitlab user home" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['home'] = "/data/git"
          runner.converge("gitlab::clone", "gitlab::start")
        end

        it "clones the gitlab repository" do
          expect(chef_run).to sync_git('/data/git/gitlab').with(
            repository: 'https://github.com/gitlabhq/gitlabhq.git',
            revision: '7-5-stable',
            user: 'git',
            group: 'git'
          )
        end
      end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::clone", "gitlab::start")
      end

      it "clones the gitlab repository" do
        expect(chef_run).to sync_git('/home/git/gitlab').with(
          repository: 'https://github.com/gitlabhq/gitlabhq.git',
          revision: '7-5-stable',
          user: 'git',
          group: 'git'
        )
      end

      describe "in development" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::clone", "gitlab::start")
        end

        it "clones the gitlab repository" do
          expect(chef_run).to sync_git('/home/git/gitlab').with(
            repository: 'https://github.com/gitlabhq/gitlabhq.git',
            revision: 'master',
            user: 'git',
            group: 'git'
          )
        end
      end

      describe "when customizing gitlab user home" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['home'] = "/data/git"
          runner.converge("gitlab::clone", "gitlab::start")
        end

        it "clones the gitlab repository" do
          expect(chef_run).to sync_git('/data/git/gitlab').with(
            repository: 'https://github.com/gitlabhq/gitlabhq.git',
            revision: '7-5-stable',
            user: 'git',
            group: 'git'
          )
        end
      end
    end
  end
end
