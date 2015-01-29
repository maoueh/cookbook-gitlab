require 'spec_helper'

describe "Gitlab Application" do
  it "is listening on port 80" do
    expect(port(80)).to be_listening
  end

  it "has a running service named gitlab" do
    expect(service("gitlab")).to be_running
  end
end
