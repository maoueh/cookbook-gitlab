#
# Cookbook Name:: gitlab
# Recipe:: start
#

gitlab = node['gitlab']

## Start Your GitLab Instance
service "gitlab" do
  supports :start => true, :stop => true, :restart => true, :status => true
  action :enable
end

service "gitlab" do
  action :nothing
  subscribes :start, "execute[rake db:migrate]"
end
