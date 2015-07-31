require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_gems under #{platform} @ #{version}" do
      cached(:chef_run) do
         ChefSpec::SoloRunner.new(platform: platform, version: version).converge("gitlab::_gems")
      end

      it "gets the latest certificate bundle" do
        expect(chef_run).to create_remote_file("Fetch the latest ca-bundle").with(owner: "git", group: "git", source: "http://curl.haxx.se/ca/cacert.pem", path: "/opt/local/etc/certs/cacert.pem")
      end

      it 'creates a gemrc in git home directory' do
        expect(chef_run).to create_template('/home/git/.gemrc').with(
          source: "gemrc.erb",
          user: "git",
          group: "git"
        )
        expect(chef_run).to render_file('/home/git/.gemrc').with_content('gem: --no-ri --no-rdoc')
      end

      it 'updates rubygems on system' do
        expect(chef_run).to run_execute('Update rubygems').with(command: "gem update --system")
      end

      describe "when customizing gitlab user home" do
        cached(:chef_run) do
           ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node.set['gitlab']['home'] = "/data/git"
          end.converge("gitlab::_gems")
        end

        it 'creates a gemrc in customized git home directory' do
          expect(chef_run).to create_template('/data/git/.gemrc').with(
            source: "gemrc.erb",
            user: "git",
            group: "git"
          )
          expect(chef_run).to render_file('/data/git/.gemrc').with_content('gem: --no-ri --no-rdoc')
        end
      end
    end
  end
end
