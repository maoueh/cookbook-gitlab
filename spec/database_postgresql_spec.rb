## NOTE!
# Currently database recipes are untested
# This should be improved when the circumstances allow
# Reasons are explained here: https://github.com/sethvargo/chefspec/blob/v3.0.1/README.md#testing-lwrps
#

require 'spec_helper'

describe "gitlab::database_postgresql" do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge("gitlab::database_postgresql") }


  describe "under ubuntu" do
    ["14.04", "12.04"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.node.set['gitlab']['database_adapter'] = "postgresql"
        runner.node.set['gitlab']['database_password'] = "datapass"
        runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
        runner.converge("gitlab::database_postgresql")
      end

      before do
        # stubbing commands because real commands are disabled
        stub_command("ls /var/lib/pgsql/data/recovery.conf").and_return(true)
        stub_command("ls /var/lib/postgresql/9.3/main/recovery.conf").and_return(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("postgresql::server")
        expect(chef_run).to include_recipe("database::postgresql")
      end

      describe "with external database" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['external_database'] = true
          runner.converge("gitlab::database_postgresql")
        end

        it "skips database setup recipe" do
          expect(chef_run).to_not include_recipe("postgresql::server")
        end
      end
    end
  end

    describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.node.set['gitlab']['database_adapter'] = "postgresql"
        runner.node.set['gitlab']['database_password'] = "datapass"
        runner.node.set['postgresql']['password']['postgres'] = "psqlpass"
        runner.converge("gitlab::database_postgresql")
      end

      before do
        # stubbing commands because real commands are disabled
        stub_command("ls /var/lib/pgsql/data/recovery.conf").and_return(true)
        stub_command("ls /var/lib/postgresql/9.3/main/recovery.conf").and_return(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("postgresql::server")
        expect(chef_run).to include_recipe("database::postgresql")
      end

      describe "with external database" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['external_database'] = true
          runner.converge("gitlab::database_postgresql")
        end

        it "skips database setup recipe" do
          expect(chef_run).to_not include_recipe("postgresql::server")
        end
      end
    end
  end
end
