require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_database_mysql under #{platform} @ #{version}" do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
          node.set['gitlab']['database_adapter'] = "mysql"
        end.converge("gitlab::_database_mysql")
      end

      it "does not set build-essential at compile time" do
        expect(chef_run.node['build-essential']['compile_time']).to eq(false)
      end

      it "configures correctly selinux::disabled recipe" do
        case platform
        when 'centos'
          expect(chef_run).to include_recipe("selinux::disabled")
        when 'ubuntu'
          expect(chef_run).to_not include_recipe("selinux::disabled")
        else
          raise "Platform #{platform} is not tested"
        end
      end

      it "creates gitlab mysql service" do
        expect(chef_run).to create_mysql_service("gitlab")
      end

      it "configures gitlab mysql config" do
        expect(chef_run).to create_mysql_config("gitlab")
      end

      it "includes database::mysql recipe" do
        expect(chef_run).to include_recipe("database::mysql")
      end

      describe "with external database" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['external_database'] = true
            node.set['gitlab']['database_adapter'] = "mysql"
          end.converge("gitlab::_database_mysql")
        end

        it "never includes selinux::disabled recipe" do
          expect(chef_run).to_not include_recipe("selinux::disabled")
        end

        it "skips creates gitlab mysql service" do
          expect(chef_run).to_not create_mysql_service("gitlab")
        end

        it "skips configure gitlab mysql config" do
          expect(chef_run).to_not create_mysql_config("gitlab")
        end

        it "still includes database::mysql recipe" do
          expect(chef_run).to include_recipe("database::mysql")
        end
      end
    end
  end
end
