require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_database_mysql under #{platform} @ #{version}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
          node.set['gitlab']['database_adapter'] = 'mysql'
        end.converge('gitlab::_database_mysql')
      end

      it 'does not set build-essential at compile time' do
        expect(chef_run.node['build-essential']['compile_time']).to eq(false)
      end

      it 'creates gitlab mysql service' do
        expect(chef_run).to create_mysql_service('gitlab')
      end

      it 'configures gitlab mysql config' do
        expect(chef_run).to create_mysql_config('gitlab')
      end

      it 'installs mysql gem into chef path' do
        expect(chef_run).to install_mysql2_chef_gem('default')
      end

      describe 'with external database' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['external_database'] = true
            node.set['gitlab']['database_adapter'] = 'mysql'
          end.converge('gitlab::_database_mysql')
        end

        it 'skips creates gitlab mysql service' do
          expect(chef_run).to_not create_mysql_service('gitlab')
        end

        it 'skips configure gitlab mysql config' do
          expect(chef_run).to_not create_mysql_config('gitlab')
        end

        it 'still installs mysql gem into chef path' do
          expect(chef_run).to install_mysql2_chef_gem('default')
        end
      end
    end
  end
end
