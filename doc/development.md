# GitLab Metal development setup

To develop for GitLab, it is recommended to install a development GitLab on metal. This is much faster than any VM-based setup, but has as disadvantage that you might have to deal with anything that is already on your system.
There is also an option of setting up a dedicated OS for GitLab, see [the directions here](doc/development_metal.md).


- Tested and confirmed working on Ubuntu 13.10

*Please read whole document before starting the setup.*

The installation process is almost the same as a [production install using Chef](https://gitlab.com/gitlab-org/cookbook-gitlab/blob/master/doc/production.md).
You use the same /tmp/solo.rb as mentioned in the production install.
It is convenient to setup GitLab under your existing user account.
In `/tmp/solo.json` configuration file, replace the occurences of `USER` and `USERGROUP` with your settings(username and group can be gathered using `id` command).

You can also alter the paths to place the code somewhere convenient, the example below places everything under home directory of `USER`:

```bash
rm -f /tmp/solo.json
cat > /tmp/solo.json << EOF
{
  "gitlab": {
    "env": "development",
    "repos_path": "/home/USER/repositories",
    "shell_path": "/home/USER/gitlab-shell",
    "ssh_port": "22",
    "user": "USER",
    "group": "USERGROUP",
    "home": "/home/USER",
    "path": "/home/USER/gitlab",
    "satellites_path": "/home/USER/gitlab-satellites"
  },

  "run_list": [
    "postfix",
    "gitlab::packages",
    "gitlab::database_postgresql",
    "gitlab::deploy"
  ]
}

EOF
```


```bash
distro="$(cat /etc/issue | awk ''NR==1'{ print $1 }')"
case "$distro" in
  Ubuntu)
    sudo apt-get update
    sudo apt-get install -y build-essential git curl # We need git to clone the cookbook, newer version will be compiled using the cookbook
  ;;
  CentOS)
    yum groupinstall -y "Development Tools"
  ;;
  *)
    echo "Your distro is not supported." 1>&2
    exit 1
  ;;
esac
```

Next run:

```bash
cd /tmp
curl -LO https://www.opscode.com/chef/install.sh && sudo bash ./install.sh -v 11.4.4
sudo /opt/chef/embedded/bin/gem install berkshelf --no-ri --no-rdoc
git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git /tmp/cookbook-gitlab
cd /tmp/cookbook-gitlab
/opt/chef/embedded/bin/berks vendor /tmp/cookbooks
cat > /tmp/solo.rb << EOF
cookbook_path    ["/tmp/cookbooks/"]
log_level        :debug
EOF
sudo chef-solo -c /tmp/solo.rb -j /tmp/solo.json
```

After installing please do:

```bash
sudo update-rc.d gitlab disable
sudo passwd -u USER
cd /home/USER/gitlab/gitlab
```


# Troubleshooting

## PostgreSQL installation problems

- Make sure your distribution is added to the postgres cookbook. The latest cookbook does not include 13.10, requiring you to add `saucy` to the list of distributions
- Only one Postgres version can be installed / running. To be sure, remove any other versions of your system if your installation runs into problems at this step.

## Error on /tmp/cookbooks/build-essential/recipes/debian.rb

Make sure there are no 404'ing links in your repos.list

```
sudo apt-get update
```

should not give any 404 link.

## Other

- Your home folder can not already contain a `./gitlab` folder! If that already exists, append a folder to the solo.json file, such as /dev (it should already exist). The `home` attribute should still point to your homefolder, independent of the GitLab installation folder.
- Unicorn.rb should have the correct path set to be able to start the server.
