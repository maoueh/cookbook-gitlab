require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_nginx under #{platform} @ #{version}" do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: platform, version: version).converge('gitlab::_nginx')
      end

      it 'installs nginx' do
        expect(chef_run).to install_package('nginx')
      end

      it 'creates a nginx template with attributes' do
        expect(chef_run).to create_template(nginx_config(platform)).with(
          source: 'nginx.erb',
          mode: 0644,
          variables: {
            path: '/home/git/gitlab',
            host: 'localhost',
            ip: '*',
            port: '80',
            ssl_certificate_path: '/etc/ssl',
            ssl_certificate_key_path: '/etc/ssl',
            client_max_body_size: '20m'
          }
        )
      end

      it 'configures gitlab home directory' do
        case platform
        when 'centos'
          expect(chef_run).to create_directory('/home/git').with(
            mode: 0755
          )
        when 'ubuntu'
          expect(chef_run).to_not create_directory('/home/git').with(
            mode: 0755
          )
        else
          fail "Platform #{platform} not tested"
        end
      end

      it 'creates a link with attributes' do
        case platform
        when 'centos'
          # No link
        when 'ubuntu'
          expect(chef_run).to create_link('/etc/nginx/sites-enabled/gitlab').with(to: '/etc/nginx/sites-available/gitlab')
        else
          fail "Platform #{platform} not tested"
        end
      end

      it 'deletes a default nginx page' do
        case platform
        when 'centos'
          expect(chef_run).to delete_file('/etc/nginx/conf.d/default.conf')
          expect(chef_run).to delete_file('/etc/nginx/conf.d/ssl.conf')
          expect(chef_run).to delete_file('/etc/nginx/conf.d/virtual.conf')
        when 'ubuntu'
          expect(chef_run).to delete_file('/etc/nginx/sites-enabled/default')
        else
          fail "Platform #{platform} not tested"
        end
      end

      it 'restarts nginx service' do
        expect(chef_run).to restart_service('nginx')
      end

      describe 'when customizing gitlab user home' do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['home'] = '/data/git'
          end.converge('gitlab::_nginx')
        end

        it 'creates a nginx template with attributes' do
          expect(chef_run).to create_template(nginx_config(platform)).with(
            source: 'nginx.erb',
            mode: 0644,
            variables: {
              path: '/data/git/gitlab',
              host: 'localhost',
              ip: '*',
              port: '80',
              ssl_certificate_path: '/etc/ssl',
              ssl_certificate_key_path: '/etc/ssl',
              client_max_body_size: '20m'
            }
          )
        end

        it 'configures gitlab home directory' do
          case platform
          when 'centos'
            expect(chef_run).to create_directory('/data/git').with(
              mode: 0755
            )
          when 'ubuntu'
            expect(chef_run).to_not create_directory('/data/git').with(
              mode: 0755
            )
          else
            fail "Platform #{platform} not tested"
          end
        end
      end

      describe 'when customizing install_nginx' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['install_nginx'] = false
          end.converge('gitlab::_nginx')
        end

        it 'does not install nginx' do
          expect(chef_run).to_not install_package('nginx')
        end
      end
    end
  end
end
