#
# Cookbook Name:: gitlab
# Recipe:: gems
#

gitlab = node['gitlab']

# To prevent random failures during bundle install, get the latest ca-bundle
execute "Fetch the latest ca-bundle" do
  command "curl http://curl.haxx.se/ca/cacert.pem --create-dirs -o /opt/local/etc/certs/cacert.pem"
  not_if { File.exists?("/opt/local/etc/certs/cacert.pem") }
end

## Install Gems without ri and rdoc
template File.join(gitlab['home'], ".gemrc") do
  source "gemrc.erb"
  user gitlab['user']
  group gitlab['group']
  notifies :run, "execute[bundle install]", :immediately
end

### without
bundle_without = []
case gitlab['database_adapter']
when 'mysql'
  bundle_without << 'postgres'
  bundle_without << 'aws'
when 'postgresql'
  bundle_without << 'mysql'
  bundle_without << 'aws'
end

case gitlab['env']
when 'production'
  bundle_without << 'development'
  bundle_without << 'test'
else
  bundle_without << 'production'
end

execute "bundle install" do
  command <<-EOS
    PATH="/usr/local/bin:$PATH"
    #{gitlab['bundle_install']} --without #{bundle_without.join(" ")}
  EOS
  cwd gitlab['path']
  user gitlab['user']
  group gitlab['group']
  action :nothing
end
