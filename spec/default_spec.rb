require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::default under #{platform} @ #{version}" do
      let(:chef_run) do
         ChefSpec::SoloRunner.new(platform: platform, version: version).converge("gitlab::default")
      end

      before do
        stub_command("test -f /var/chef/cache/git-2.1.4.tar.gz").and_return(true)
        stub_command("git --version | grep 2.1.4").and_return(true)
        stub_command("git --version >/dev/null").and_return(true)
        stub_command("ls /var/lib/pgsql/data/recovery.conf").and_return(true)
        stub_command("ls /var/lib/postgresql/9.3/main/recovery.conf").and_return(true)
      end

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("gitlab::_packages")
        expect(chef_run).to include_recipe("gitlab::_users")
        expect(chef_run).to include_recipe("gitlab::_redis")
        expect(chef_run).to include_recipe("gitlab::_gitlab_shell")
        expect(chef_run).to include_recipe("gitlab::_clone")
        expect(chef_run).to include_recipe("gitlab::_gems")
        expect(chef_run).to include_recipe("gitlab::_install")
        expect(chef_run).to include_recipe("gitlab::_nginx")
      end

      it "includes database_postgresql by default" do
        expect(chef_run).to include_recipe("gitlab::_database_postgresql")
      end

      it "does not include database_mysql by default" do
        expect(chef_run).to_not include_recipe("gitlab::_database_mysql")
      end

      describe "when database adapter is mysql" do
        let(:chef_run) do
           ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['database_adapter'] = "mysql"
          end.converge("gitlab::default")
        end

        it "does not include database postgresql" do
          expect(chef_run).to_not include_recipe("gitlab::_database_postgresql")
        end

        it "includes database mysql" do
          expect(chef_run).to include_recipe("gitlab::_database_mysql")
        end
      end
    end
  end
end
