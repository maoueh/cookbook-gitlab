require 'spec_helper'

describe "gitlab::gitlab_shell_clone" do
  describe "under ubuntu" do
    ["14.04"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gitlab_shell_clone")
      end

      it "clones the gitlab-shell repository" do
        expect(chef_run).to sync_git('/home/git/gitlab-shell').with(
          repository: 'https://github.com/gitlabhq/gitlab-shell.git',
          revision: "v2.4.0",
          user: 'git',
          group: 'git'
        )
      end

      describe "in development" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::gitlab_shell_clone")
        end

        it "clones the gitlab-shell repository" do
          expect(chef_run).to sync_git('/home/git/gitlab-shell').with(
            repository: 'https://github.com/gitlabhq/gitlab-shell.git',
            revision: "master",
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
          runner.converge("gitlab::gitlab_shell_clone")
        end

        it "clones the gitlab-shell repository" do
          expect(chef_run).to sync_git('/data/git/gitlab-shell')
        end
      end
    end
  end

  describe "under centos" do
    ["6.4"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::gitlab_shell_clone")
      end

      it "clones the gitlab-shell repository" do
        expect(chef_run).to sync_git('/home/git/gitlab-shell').with(
          repository: 'https://github.com/gitlabhq/gitlab-shell.git',
          revision: "v2.4.0",
          user: 'git',
          group: 'git'
        )
      end

      describe "in development" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::gitlab_shell_clone")
        end

        it "clones the gitlab-shell repository" do
          expect(chef_run).to sync_git('/home/git/gitlab-shell').with(
            repository: 'https://github.com/gitlabhq/gitlab-shell.git',
            revision: "master",
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
          runner.converge("gitlab::gitlab_shell_clone")
        end

        it "clones the gitlab-shell repository" do
          expect(chef_run).to sync_git('/data/git/gitlab-shell')
        end
      end
    end
  end
end
