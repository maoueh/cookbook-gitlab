require 'spec_helper'

describe "gitlab::packages" do
  describe "under ubuntu" do
    ["14.04"].each do |version|
      let(:chef_run) { ChefSpec::SoloRunner.new(platform: "ubuntu", version: version).converge("gitlab::redis") }

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("redisio::install")
        expect(chef_run).to include_recipe("redisio::enable")
      end

      it "creates redis socket directory" do
        expect(chef_run).to create_directory("/var/run/redis/sockets").with(
          user: 'redis',
          group: 'git',
          mode: 0750
        )
      end
    end
  end

  describe "under centos" do
    ["6.4"].each do |version|
      let(:chef_run) { ChefSpec::SoloRunner.new(platform: "centos", version: version).converge("gitlab::redis") }

      it "includes recipes from external cookbooks" do
        expect(chef_run).to include_recipe("redisio::install")
        expect(chef_run).to include_recipe("redisio::enable")
      end

      it "creates redis socket directory" do
        expect(chef_run).to create_directory("/var/run/redis/sockets").with(
          user: 'redis',
          group: 'git',
          mode: 0750
        )
      end
    end
  end
end
