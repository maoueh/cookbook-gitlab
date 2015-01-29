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
          mode: "0770"
        )
      end

      it "changes redis init.d exec command" do
        case platform
        when 'centos'
          code = "sed -i s#'EXEC=\"runuser.*\"'#'EXEC=\"runuser redis -g git -c \\\\\"/usr/local/bin/redis-server /etc/redis/${REDISNAME}.conf\\\\\"\"'# /etc/init.d/redis0"
        when 'ubuntu'
          code = "sed -i s#'EXEC=\"su.*\"'#'EXEC=\"sudo -u redis -g git /usr/local/bin/redis-server /etc/redis/${REDISNAME}.conf\"'# /etc/init.d/redis0"
        end

        expect(chef_run).to run_bash("change redis init.d exec command").with(
          code: code
        )
      end
    end
  end
end
