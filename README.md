GitLab Cookbook
===============

Chef cookbook with recipes to install GitLab and its dependencies.

## Information

This cookbook is a forked of the now deprecated [GitLab Team cookbook](https://gitlab.com/gitlab-org/cookbook-gitlab)
to install and configure GitLab.

I continue to update this cookbook to keep it in-sync with GitLab releases. However,
note that I'm always lagging a bit behind the release because when I update this
cookbook, I also update my instance at the same time and hence, I prefer to wait
two or three weeks before updating for potential patches.

### Versions

* GitLab: 7.6.x
* GitLab Shell: 2.4.0
* Ruby: 2.1.2
* Redis: 2.6.13
* Git: 2.0.0
* Nginx: 1.1.19
* PostgreSQL: 9.3
* MySQL: 5.5.34

### Compatible operating systems

Cookbook should be compatible with the following operating systems,
only CentOS is fully tested right now.

* Ubuntu (12.04, 12.10, 14.04)
* RHEL/CentOS (6.5)

## Recipes

### default

Default recipe, it includes two recipes: `setup` and `deploy`. Default recipe is
being used to do a complete GitLab installation. Simply edit attributes to fit
your needs and launch `gitlab::default` recipe.

## Development

Install required ruby dependencies.

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
