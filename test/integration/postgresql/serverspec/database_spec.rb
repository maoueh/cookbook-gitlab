require 'spec_helper'

describe 'PostgreSQL Database' do
  it 'is listening on port 5432' do
    expect(port(5432)).to be_listening
  end

  it 'has a running service named postgresql' do
    if os[:family] == 'redhat'
      expect(service('postgresql-9.3')).to be_running
    else
      expect(service('postgresql')).to be_running
    end
  end
end
