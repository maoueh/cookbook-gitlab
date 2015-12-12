require 'spec_helper'

describe 'Redis Database' do
  describe file('/var/run/redis/sockets/redis.sock') do
    it { should be_socket }
    it { should be_owned_by('redis') }
    it { should be_grouped_into('git') }
  end

  it 'has a running service named redis0' do
    expect(service('redis0')).to be_running
  end
end
