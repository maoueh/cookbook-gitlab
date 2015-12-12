require 'spec_helper'

describe 'MySQL Database' do
  it 'is listening on port 3306' do
    expect(port(3306)).to be_listening
  end

  it 'has a running service named mysql-gitlab' do
    expect(service('mysql-gitlab')).to be_running
  end
end
