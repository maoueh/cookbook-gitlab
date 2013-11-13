# User
default['gitlab']['development']['user'] = "git"
default['gitlab']['development']['group'] = "git"
default['gitlab']['development']['home'] = "/home/git"

# GitLab shell
default['gitlab']['development']['shell_path'] = "/home/git/gitlab-shell"

# GitLab hq
default['gitlab']['development']['revision'] = "master"
default['gitlab']['development']['path'] = "/home/git/gitlab"

# GitLab shell config
default['gitlab']['development']['repos_path'] = "/home/git/repositories"

# GitLab hq config
default['gitlab']['development']['satellites_path'] = "/home/git/gitlab-satellites"

# Setup environments
default['gitlab']['development']['environments'] = %w{development test}
