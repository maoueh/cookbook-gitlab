require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_database_postgresql under #{platform} @ #{version}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: platform, version: version).converge("gitlab::_database_postgresql")
      end

      before do
        stub_command("ls /var/lib/pgsql/data/recovery.conf").and_return(false)
        stub_command("ls /var/lib/postgresql/9.3/main/recovery.conf").and_return(false)
      end

      it "sets build-essential at compile time" do
        expect(chef_run.node['build-essential']['compile_time']).to eq(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("postgresql::server")
        expect(chef_run).to include_recipe("database::postgresql")
      end

      describe "with external database" do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['external_database'] = true
          end.converge("gitlab::_database_postgresql")
        end

        it "skips database setup recipe" do
          expect(chef_run).to_not include_recipe("postgresql::server")
        end

        it "still includes database::postgresql reci[e" do
          expect(chef_run).to include_recipe("database::postgresql")
        end
      end
    end
  end
end
