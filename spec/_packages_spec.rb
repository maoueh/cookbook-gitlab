require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_packages under #{platform} @ #{version}" do
      let(:chef_run) { ChefSpec::SoloRunner.new(platform: platform, version: version).converge("gitlab::_packages") }

      before do
        stub_command("test -f /var/chef/cache/git-2.1.4.tar.gz").and_return(false)
        stub_command("git --version | grep 2.1.4").and_return(false)
        stub_command("git --version >/dev/null").and_return(false)
      end

      case platform
      when 'ubuntu'
        it "includes platform package repository recipe" do
          expect(chef_run).to include_recipe("apt::default")
          expect(chef_run).to_not include_recipe("yum-epel::default")
        end
      when 'centos'
        it "includes platform package repository recipe" do
          expect(chef_run).to_not include_recipe("apt::default")
          expect(chef_run).to include_recipe("yum-epel::default")
        end
      else
        raise "Platform #{platform} is not tested"
      end

      it "installs all default packages" do
        packages = chef_run.node['gitlab']['packages']
        packages.each do |pkg|
          expect(chef_run).to install_package(pkg)
        end
      end

      it "should not install package git" do
        expect(chef_run).to_not install_package("git")
        expect(chef_run).to_not install_package("git-core")
      end

      it 'includes git source recipe' do
        expect(chef_run).to include_recipe("git::source")
      end

      it "includes ruby_build recipe" do
        expect(chef_run).to include_recipe("ruby_build::default")
      end

      it "installs bundler gem" do
        expect(chef_run).to install_gem_package("bundler")
      end
    end
  end
end
