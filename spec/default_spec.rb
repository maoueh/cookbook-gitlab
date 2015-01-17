require 'spec_helper'

describe "gitlab::default" do
  describe "under ubuntu" do
    ["14.04"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::default")
      end

      before do
        stub_command("test -f /var/chef/cache/git-2.1.4.tar.gz").and_return(true)
        stub_command("git --version | grep 2.1.4").and_return(true)
        stub_command("git --version >/dev/null").and_return(true)
        stub_command("ls /var/lib/pgsql/data/recovery.conf").and_return(true)
        stub_command("ls /var/lib/postgresql/9.3/main/recovery.conf").and_return(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("gitlab::setup")
        expect(chef_run).to include_recipe("gitlab::deploy")
      end

      describe "when in development environment" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::default")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::setup")
          expect(chef_run).to include_recipe("gitlab::deploy")
        end
      end
    end
  end

  describe "under centos" do
    ["6.4"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::default")
      end

      before do
        stub_command("test -f /var/chef/cache/git-2.1.4.tar.gz").and_return(true)
        stub_command("git --version | grep 2.1.4").and_return(true)
        stub_command("git --version >/dev/null").and_return(true)
        stub_command("ls /var/lib/pgsql/data/recovery.conf").and_return(true)
        stub_command("ls /var/lib/postgresql/9.3/main/recovery.conf").and_return(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("gitlab::setup")
        expect(chef_run).to include_recipe("gitlab::deploy")
      end


      describe "when in development environment" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "development"
          runner.converge("gitlab::default")
        end

        it "includes recipes from external cookbooks" do
          expect(chef_run).to include_recipe("gitlab::setup")
          expect(chef_run).to include_recipe("gitlab::deploy")
        end
      end
    end
  end
end
