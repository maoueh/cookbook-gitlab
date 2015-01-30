# GitLab Cookbook

[![Build Status](https://travis-ci.org/maoueh/cookbook-gitlab.svg?branch=master)](https://travis-ci.org/maoueh/cookbook-gitlab)

Chef cookbook with recipes to install GitLab and its dependencies.

## Information

This cookbook is a forked of the now deprecated [GitLab Team cookbook](https://gitlab.com/gitlab-org/cookbook-gitlab)
to install and configure GitLab.

I continue to update this cookbook to keep it in-sync with GitLab releases. However,
note that I'm always lagging a bit behind the release because when I update this
cookbook, I also update my instance at the same time and hence, I prefer to wait
two or three weeks before updating for potential patches.

Other than keeping the cookbook up to date with GitLab, I add little to no
new features to this cookbook. I'm not investing a lot of time maintaining
this cookbook.

### Semantic Versioning

For this cookbook, there is two major concerns about semantic versioning.
We want an easy to match this cookbook and GitLab version installed and
want also to ensure users upgrading between versions of this cookbook.

As such, here the semantic versioning used by this cookbook.

 * The major version is used to denote breaking changes within this cookbook.
 * The minor and patch versions are used for version of GitLab installed.

For example, current version is `1.7.7` meaning we are installing GitLab version
`7.7`.

Bug fixes and new features not breaking compatibility will be performed
between GitLab releases so going to `1.7.8` or `1.8.0` for example.

Breaking changes within the cookbook are made only on the major version,
but will feel weird as minor and patch will still follow Gitlab version.

For example, next breaking change version could be `2.7.9` for example.

### Versions

* GitLab: 7.7.x
* GitLab Shell: 2.4.0
* Ruby: 2.1.2
* Redis: 2.8.17
* Git: 2.1.4
* Nginx: 1.1.19
* PostgreSQL: 9.3
* MySQL: 5.5.34

### Compatible operating systems

Cookbook should be compatible with the following operating systems,
only CentOS is fully tested right now.

 * Ubuntu (12.04, 12.10, 14.04)
 * RHEL/CentOS (6.5)

### SELinux

On RHEL platforms,`selinux` is disabled by default in the cookbook.
The main reason for this is because, well, because I'm lazy and I did not
want to spend the time necessary for now to fix this.

The attributes and various access must be defined correctly for Nginx
to access GitLab content in home directory. And when using MySQL, there
is also some attributes that must be defined correctly.

Hence, for simplicity, instead of implementing it in the cookbook, I decided
to disable `selinux` completely. If you do not want this behavior, you can
do the following.

Wrap this cookbook using a wrapper cookbook. Set the attribute  `node['selinux']['state']`
to `:enforcing` (or `:permissive`). Then, implement the necessary to make it
work.

Here some preliminary data information to make mysql work with SELinux
(also a good remainder for me for later on):

    semanage fcontext -a -t mysqld_db_t "/var/lib/mysql-gitlab(/.*)?"
    semanage fcontext -a -t mysqld_db_t "/var/run/mysql-gitlab(/.*)?"
    semanage fcontext -a -t mysqld_db_t "/var/log/mysql-gitlab(/.*)?"

On my side, I really want to make it work correctly at some point in
time. I'm planning to use [chef-selinuxpolicy cookbook](https://github.com/BackSlasher/chef-selinuxpolicy).
If you give it a shot, tell me how it was in the issues.

Finally, sorry http://stopdisablingselinux.com/.

## Recipes

### default

Default recipe, it includes two recipes: `setup` and `deploy`. Default recipe is
being used to do a complete GitLab installation. Simply edit attributes to fit
your needs and launch `gitlab::default` recipe.

## Development

Install required ruby dependencies for development using bundler, then run
berkshelf to install cookbook dependencies and finally run all the
development tools including `foodcritic` and spec tests.

```
bundle install
bundle exec berks install
bundle exec rake test
```

### Windows

Testing using `ChefSpec` on Windows needs a little bit more work. The problem
is that it's not possible to completely emulate the tested platform with
Chef, specially when on Windows.

For example, even if tested platform is set to `CentOS`, some parts of Chef
codebase are still assuming Windows, for example when validating the mode
use in file resources. In the GitLab cookbook, there is an octal mode of
`02777` which is invalid when run on Windows. This prevents the test suite
from running correctly.

For these cases, merge the `windows-test` branch into your branch prior
running the tests. Don't forget to remove it when finished.

## Acknowledgements

This cookbook was based on a [cookbbook by ogom](https://github.com/ogom/cookbook-gitlab), thank you
ogom! We would also like to thank Eric G. Wolfe for making the [first cookbook for CentOS](https://github.com/atomic-penguin/cookbook-gitlab), thanks Eric!

This cookboook has been forked from [GitLab Team cookbook](https://gitlab.com/gitlab-org/cookbook-gitlab)
after it was deprecated in favor of the omnibus package. Thank you for keeping the cookbook up to date
until version 7.4.0 of GitLab.

## Contributing

Please see the [Contributing doc](CONTRIBUTING.md).

## Links

* [GitLab Manual Installation](https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md)

## Authors

* [ogom](https://github.com/ogom)
* [Marin Jankovski](https://github.com/maxlazio)
* [Matthieu Vachon](https://github.com/maoueh)

## License

* [MIT](LICENSE)
