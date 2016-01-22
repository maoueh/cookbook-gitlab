# Upgrade Guide

Purpose of this guide is to give you the information you need
to upgrade from one version of GitLab to another one.

Order is ascending, so upgrades instructions from earlier versions are
listed last.

### Old Cookbook to 0.7.6

The old cookbook has been developed by GitLab team directly. This new
version has been heavily refactored in regards to recipes names.

The other big changes is the bump of some external dependencies. The main
changes are for MySQL which completely changed default paths. Also, redis
was updated to its latest version. Here the steps that should be
performed prior migrating your node.

 1. Stop all services

        service gitlab stop
        service mysqld stop
        service redis0 stop # Maybe on another name

 2. Remove all old redis references

        rm -rf /usr/local/bin/redis*
        rm -rf /var/lib/redis

 3. Copy database to new location directly

        cp -Rp /var/lib/mysql /var/lib/mysql-gitlab

 4. Converge node

 5. Test everything was correct and remove old database backup

       rm -rf /var/lib/mysql

# Cookbook 2.8.1 to 3.8.2

In the move from 8.1 to 8.2, gitlab renamed `gitlab-git-http-server` to
`gitlab-workhorse`. At the same times, I moved some attributes around
to make it easier to develop.

## Attributes

 * `node['gitlab']['git_http_server']` to `node['gitlab']['workhorse']`

 * `node['gitlab']['oauth_enabled']` to `node['gitlab']['oauth']['enabled']`
 * `node['gitlab']['oauth_block_auto_created_users']` to `node['gitlab']['oauth']['block_auto_created_users']`
 * `node['gitlab']['oauth_auto_link_ldap_user']` to `node['gitlab']['oauth']['auto_link_ldap_user']`
 * `node['gitlab']['oauth_allow_single_sign_on']` to `node['gitlab']['oauth']['allow_single_sign_on']`
 * `node['gitlab']['oauth_providers']` to `node['gitlab']['oauth']['providers']`

 * `node['gitlab']['default_project_features']['issues']` to `node['gitlab']['features']['issues']`
 * `node['gitlab']['default_project_features']['merge_requests']` to `node['gitlab']['features']['merge_requests']`
 * `node['gitlab']['default_project_features']['wiki']` to `node['gitlab']['features']['wiki']`
 * `node['gitlab']['default_project_features']['snippets']` to `node['gitlab']['features']['snippets']`
 * `node['gitlab']['default_project_features']['builds']` to `node['gitlab']['features']['builds']`

 * `node['gitlab']['gravatar']` to `node['gitlab']['gravatar']['enabled']`
 * `node['gitlab']['gravatar_plain_url'] to `node['gitlab']['gravatar']['plain_url']`
 * `node['gitlab']['gravatar_ssl_url'] to `node['gitlab']['gravatar']['ssl_url']`

## Git HTTP Server Removal

Here the steps needed if you want to actually remove the old references to
`gitlab-git-http-server`. These steps must be performed after GitLab instance
has been upgraded to `8.2` (or higher).

    rm -rf /home/git/gitlab-git-http-server

That's it. Change `/home/git` to wherever is your git user home directory.

