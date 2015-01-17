require 'spec_helper'

describe "gitlab::nginx" do
  describe "under ubuntu" do
    ["14.04"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::nginx")
      end

      it "installs nginx" do
        expect(chef_run).to install_package('nginx')
      end

      it 'creates a nginx template with attributes' do
        expect(chef_run).to create_template('/etc/nginx/sites-available/gitlab').with(
          source: 'nginx.erb',
          mode: 0644,
          variables: {
            path: "/home/git/gitlab",
            host: "localhost",
            ip: "*",
            port: "80",
            ssl_certificate_path: "/etc/ssl",
            ssl_certificate_key_path: "/etc/ssl",
            client_max_body_size: "20m"
          }
        )
      end

      it 'does not create a directory' do
        expect(chef_run).to_not create_directory('/home/git').with(
          mode: 0755
        )
      end

      it 'creates a link with attributes' do
        expect(chef_run).to create_link('/etc/nginx/sites-enabled/gitlab').with(to: '/etc/nginx/sites-available/gitlab')
      end

      it 'deletes a default nginx page' do
        expect(chef_run).to delete_file('/etc/nginx/sites-enabled/default')
      end

      it 'restarts nginx service' do
        expect(chef_run).to restart_service('nginx')
      end

      describe "when customizing gitlab user home" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['home'] = "/data/git"
          runner.converge("gitlab::nginx")
        end

        it 'creates a nginx template with attributes' do
          expect(chef_run).to create_template('/etc/nginx/sites-available/gitlab').with(
            source: 'nginx.erb',
            mode: 0644,
            variables: {
              path: "/data/git/gitlab",
              host: "localhost",
              ip: "*",
              port: "80",
              ssl_certificate_path: "/etc/ssl",
              ssl_certificate_key_path: "/etc/ssl",
              client_max_body_size: "20m"
            }
          )
        end

        it 'does not create a directory' do
          expect(chef_run).to_not create_directory('/data/git')
        end
      end

      describe "when customizing install_nginx" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['install_nginx'] = false
          runner.converge("gitlab::nginx")
        end

        it 'does not install nginx' do
          expect(chef_run).to_not install_package('nginx')
        end
      end
    end
  end

    describe "under centos" do
    ["6.4"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::nginx")
      end

      it "installs nginx" do
        expect(chef_run).to install_package('nginx')
      end

      it 'creates a nginx template with attributes' do
        expect(chef_run).to create_template('/etc/nginx/conf.d/gitlab.conf').with(
          source: 'nginx.erb',
          mode: 0644,
          variables: {
            path: "/home/git/gitlab",
            host: "localhost",
            ip: "*",
            port: "80",
            ssl_certificate_path: "/etc/ssl",
            ssl_certificate_key_path: "/etc/ssl",
            client_max_body_size: "20m"
          }
        )
      end

      it 'creates a directory' do
        expect(chef_run).to create_directory('/home/git').with(
          mode: 0755
        )
      end

      it 'does not create a link' do
        expect(chef_run).to_not create_link('/etc/nginx/sites-enabled/gitlab').with(to: '/etc/nginx/sites-available/gitlab')
      end

      it 'restarts nginx service' do
        expect(chef_run).to restart_service('nginx')
      end

      describe "when customizing gitlab user home" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['home'] = "/data/git"
          runner.converge("gitlab::nginx")
        end

        it 'creates a nginx template with attributes' do
          expect(chef_run).to create_template('/etc/nginx/conf.d/gitlab.conf').with(
            source: 'nginx.erb',
            mode: 0644,
            variables: {
              path: "/data/git/gitlab",
              host: "localhost",
              ip: "*",
              port: "80",
              ssl_certificate_path: "/etc/ssl",
              ssl_certificate_key_path: "/etc/ssl",
              client_max_body_size: "20m"
            }
          )
        end

        it 'creates a directory' do
          expect(chef_run).to create_directory('/data/git')
        end
      end

      describe "when customizing install_nginx" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
          runner.node.set['gitlab']['env'] = "production"
          runner.node.set['gitlab']['install_nginx'] = false
          runner.converge("gitlab::nginx")
        end

        it 'does not install nginx' do
          expect(chef_run).to_not install_package('nginx')
        end
      end
    end
  end
end
