require 'spec_helper'

supported_platforms.each do |platform, versions|
  versions.each do |version|
    describe "gitlab::_redis under #{platform} @ #{version}" do
      let(:chef_run) do
         ChefSpec::SoloRunner.new(platform: platform, version: version).converge("gitlab::_redis")
      end

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
