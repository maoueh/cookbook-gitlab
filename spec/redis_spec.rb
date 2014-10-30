require 'spec_helper'

describe "gitlab::packages" do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge("gitlab::redis") }

  describe "under ubuntu" do
    ["14.04", "12.04"].each do |version|
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

      # FIXME: When using this, service is nil and expect cannot work
      #it "subscribes to redis socket directory changes" do
      #  service = chef_run.service('redis6379')
      #  expect(service).to subscribe_to('directory[/var/run/redis/sockets]').immediately
      #end
    end
  end

  describe "under centos" do
    ["5.8", "6.4"].each do |version|
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

      # FIXME: When using this, service is nil and expect cannot work
      #it "subscribes to redis socket directory changes" do
      #  service = chef_run.service('redis6379')
      #  expect(service).to subscribe_to('directory[/var/run/redis/sockets]').immediately
      #end
    end
  end
end
