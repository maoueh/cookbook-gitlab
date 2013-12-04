#
# Cookbook Name:: gitlab
# Recipe:: nginx
#

gitlab = node['gitlab']

# 7. Nginx
## Installation
package "nginx" do
  action :install
end

## Site Configuration
path = platform_family?("rhel") ? "/etc/nginx/conf.d/gitlab.conf" : "/etc/nginx/sites-available/gitlab"
template path do
  source "nginx.erb"
  mode 0644
  variables({
    :path => gitlab['path'],
    :host => gitlab['host'],
    :port => gitlab['port'],
    :url => gitlab['url'],
    :ssl_certificate_path => gitlab['ssl_certificate_path'],
    :ssl_certificate_key_path => gitlab['ssl_certificate_key_path']
  })
end

if platform_family?("rhel")
  directory gitlab['home'] do
    mode 0755
  end

  %w( default.conf ssl.conf virtual.conf ).each do |conf|
    file "/etc/nginx/conf.d/#{conf}" do
      action :delete
    end
  end
else
  link "/etc/nginx/sites-enabled/gitlab" do
    to "/etc/nginx/sites-available/gitlab"
  end

  file "/etc/nginx/sites-enabled/default" do
    action :delete
  end
end

if gitlab['ssl_certificate_path'] && gitlab['ssl_certificate_key_path']
  directory "/etc/nginx/ssl/" do
    recursive true
    mode 0755
  end

  file "/etc/nginx/ssl/#{gitlab['host']}.crt" do
    content gitlab['ssl_certificate']
    mode 0600
  end

  file "/etc/nginx/ssl/#{gitlab['host']}.key" do
    content gitlab['ssl_certificate_key']
    mode 0600
  end
end
## Restart
service "nginx" do
  action :restart
end
