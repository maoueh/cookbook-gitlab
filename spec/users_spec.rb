require 'spec_helper'

describe "gitlab::users" do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge("gitlab::users") }


  describe "under ubuntu" do
    ["14.04", "12.04"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "ubuntu", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::users")
      end

      it "creates a user that will run gitlab" do
        expect(chef_run).to create_user('git')
      end

      it 'locks a created user' do
        expect(chef_run).to lock_user('git')
      end
    end
  end

    describe "under centos" do
    ["5.8", "6.4"].each do |version|
      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: "centos", version: version)
        runner.node.set['gitlab']['env'] = "production"
        runner.converge("gitlab::users")
      end

      it "creates a user that will run gitlab" do
        expect(chef_run).to create_user('git')
      end

      it 'locks a created user' do
        expect(chef_run).to lock_user('git')
      end
    end
  end
end
