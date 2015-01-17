require 'spec_helper'

describe "gitlab::packages" do
  describe "under ubuntu" do
    ["14.04"].each do |version|
      let(:chef_run) { ChefSpec::SoloRunner.new(platform: "ubuntu", version: version).converge("gitlab::packages") }

      before do
        stub_command("test -f /var/chef/cache/git-2.1.4.tar.gz").and_return(true)
        stub_command("git --version | grep 2.1.4").and_return(true)
      end

      it "includes platform package repository recipe" do
        expect(chef_run).to include_recipe("apt::default")
        expect(chef_run).to_not include_recipe("yum-epel::default")
      end

      it "installs all default packages" do
        packages = chef_run.node['gitlab']['packages']
        packages.each do |pkg|
          expect(chef_run).to install_package(pkg)
        end
      end

      it "should not install package git" do
        expect(chef_run).to_not install_package("git")
      end

      it 'includes git source recipe' do
        expect(chef_run).to include_recipe("git::source")
      end
    end
  end

  describe "under centos" do
    ["6.4"].each do |version|
      let(:chef_run) { ChefSpec::SoloRunner.new(platform: "centos", version: version).converge("gitlab::packages") }

      before do
        stub_command("test -f /var/chef/cache/git-2.1.4.tar.gz").and_return(true)
        stub_command("git --version | grep 2.1.4").and_return(true)
      end

      it "includes platform package repository recipe" do
        expect(chef_run).to_not include_recipe("apt::default")
        expect(chef_run).to include_recipe("yum-epel::default")
      end

      it "installs all default packages" do
        packages = chef_run.node['gitlab']['packages']
        packages.each do |pkg|
          expect(chef_run).to install_package(pkg)
        end
      end

      it "should not install package git" do
        expect(chef_run).to_not install_package("git")
      end

      it 'includes git source recipe' do
        expect(chef_run).to include_recipe("git::source")
      end
    end
  end
end
