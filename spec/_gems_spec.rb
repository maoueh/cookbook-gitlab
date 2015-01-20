require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_gems under #{platform} @ #{version}" do
      let(:chef_run) do
         ChefSpec::SoloRunner.new(platform: platform, version: version).converge("gitlab::_gems")
      end

      it "gets the latest certificate bundle" do
        expect(chef_run).to create_remote_file("Fetch the latest ca-bundle").with(owner: "git", group: "git", source: "http://curl.haxx.se/ca/cacert.pem", path: "/opt/local/etc/certs/cacert.pem")
      end

      it 'updates rubygems on system' do
        expect(chef_run).to run_execute('Update rubygems').with(command: "gem update --system")
      end

      it 'executes bundle install with correct arguments' do
        resource = chef_run.find_resource(:execute, 'bundle install')

        expect(resource.command).to eq("SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem PATH=#{env_path(chef_run.node)} bundle install --path=.bundle --deployment --no-ri --no-rdoc --without development test mysql")
        expect(resource.user).to eq("git")
        expect(resource.group).to eq("git")
        expect(resource.cwd).to eq("/home/git/gitlab")
      end

      describe "when using mysql" do
        let(:chef_run) do
           ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['database_adapter'] = "mysql"
          end.converge("gitlab::_gems")
        end

        it 'executes bundle install with correct arguments' do
          resource = chef_run.find_resource(:execute, 'bundle install')

          expect(resource.command).to eq("SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem PATH=#{env_path(chef_run.node)} bundle install --path=.bundle --deployment --no-ri --no-rdoc --without development test postgresql")
          expect(resource.user).to eq("git")
          expect(resource.group).to eq("git")
          expect(resource.cwd).to eq("/home/git/gitlab")
        end
      end

      describe "when customizing gitlab user home" do
        let(:chef_run) do
           ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['home'] = "/data/git"
          end.converge("gitlab::_gems")
        end

        it 'executes bundle install in customized working directory' do
          resource = chef_run.find_resource(:execute, 'bundle install')

          expect(resource.cwd).to eq("/data/git/gitlab")
        end
      end
    end
  end
end
