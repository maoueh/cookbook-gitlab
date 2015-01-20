#
# Cookbook Name:: gitlab
# Recipe:: gems
#

gitlab = node['gitlab']

# To prevent random failures during bundle install, get the latest ca-bundle and update rubygems

directory "/opt/local/etc/certs/" do
  owner gitlab['user']
  group gitlab['group']
  recursive true
  mode 0755
end

remote_file "Fetch the latest ca-bundle" do
  source "http://curl.haxx.se/ca/cacert.pem"
  path "/opt/local/etc/certs/cacert.pem"
  owner gitlab['user']
  group gitlab['group']
  mode 0755
  action :create
end

execute "Update rubygems" do
  command "gem update --system"
end

execute "bundle install" do
  command GitLab.bundle_install(node)
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action File.exists?("#{gitlab['home']}/Gemfile.lock") ? :nothing : :run
  subscribes :run, "git[clone gitlabhq source]", :immediately
end
