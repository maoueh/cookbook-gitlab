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
