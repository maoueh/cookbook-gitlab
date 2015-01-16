## NOTE!
# Currently database recipes are untested
# This should be improved when the circumstances allow
# Reasons are explained here: https://github.com/sethvargo/chefspec/blob/v3.0.1/README.md#testing-lwrps
#

require 'spec_helper'

describe "gitlab::database_mysql" do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge("gitlab::database_mysql") }


  describe "under ubuntu" do
    ["12.04", "14.04"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.node.set['gitlab']['database_adapter'] = "mysql"
        runner.node.set['gitlab']['database_password'] = "datapass"
        runner.node.set['mysql']['initial_root_password'] = "rootpass"
        runner.converge("gitlab::database_mysql")
      end

#      before do
#        stub_command("/usr/bin/mysql -u root -e 'show databases;'").and_return(true)
#        stub_command("\"/usr/bin/mysql\" -u root -e 'show databases;'").and_return(true)
#      end

      it "creates gitlab mysql service" do
        expect(chef_run).to create_mysql_service("gitlab")
      end

      it "includes database::mysql recipe" do
        expect(chef_run).to include_recipe("database::mysql")
      end

      describe "with external database" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['external_database'] = true
          runner.converge("gitlab::database_mysql")
        end

        it "skips creates gitlab mysql service" do
          expect(chef_run).to_not create_mysql_service("gitlab")
        end

        it "still includes database::mysql recipe" do
          expect(chef_run).to include_recipe("database::mysql")
        end
      end
    end
  end

    describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.node.set['gitlab']['database_adapter'] = "mysql"
        runner.node.set['gitlab']['database_password'] = "datapass"
        runner.node.set['mysql']['initial_root_password'] = "rootpass"
        runner.converge("gitlab::database_mysql")
      end

#      before do
#        stub_command("/usr/bin/mysql -u root -e 'show databases;'").and_return(true)
#        stub_command("\"/usr/bin/mysql\" -u root -e 'show databases;'").and_return(true)
#      end

      it "creates gitlab mysql service" do
        expect(chef_run).to create_mysql_service("gitlab")
      end

      describe "with external database" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['external_database'] = true
          runner.converge("gitlab::database_mysql")
        end

        it "skips creates gitlab mysql service" do
          expect(chef_run).to_not create_mysql_service("gitlab")
        end

        it "still includes database::mysql recipe" do
          expect(chef_run).to include_recipe("database::mysql")
        end
      end
    end
  end
end
