# GitLab development setup

To develop GitLab we install it directly on your machine (it runs on metal). A metal install is much faster than the old deprecated installation method inside a virtual machine where a single page load could take take minutes. A disadvantage of a metal install that you might run into conflicts because some programs are already on your system. *Please read the whole document including the troubleshooting and limitations section before starting the setup as it can alter your system installation.*

This guide is tested and confirmed working on:

* Ubuntu 13.10
* Please send merge request to add other OS's you've tested it on.

The installation process is almost the same as a [production install using Chef](https://gitlab.com/gitlab-org/cookbook-gitlab/blob/master/doc/production.md).
You use the same `/tmp/solo.rb` as mentioned in the production install.

```bash
curl -o /tmp/solo.json https://gitlab.com/gitlab-org/cookbook-gitlab/raw/master/solo.json.production_example
```

It is convenient to setup GitLab under your existing user account.
In `/tmp/solo.json` configuration file, replace the occurences of `USER` and `USERGROUP` with your settings(username and group can be gathered using `id` command).

You can also alter the paths to place the code somewhere convenient, the example below places everything under home directory of `USER`:

```bash
rm -f /tmp/solo.json
cat > /tmp/solo.json << EOF
{
  "gitlab": {
    "env": "development",
    "compile_ruby": false,
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
    "gitlab::default"
  ]
}

EOF
```

Add the required development tools for your operating system:

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

Run the cookbook:

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

After installing GitLab using the cookbook navigate to the source directory:

```bash
cd /home/USER/gitlab/gitlab
```

and follow [the readme instructions to run it in development mode](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/README.md#run-in-development-mode).

*Note* SSH push won't work on metal setup but you can still clone and push using `http`.

# Troubleshooting and limitations

## Git configuration

Running the cookbook will set your git config to:
user.name=GitLab
user.email=gitlab@localhost

Check with `git config --list` and run the following to correct it:

```bash
$ git config --global user.name "Jane Doe"
$ git config --global user.email janedoe@example.com
```

## PostgreSQL installation problems

- Make sure your distribution is added to the postgres cookbook. The latest cookbook does not include 13.10, requiring you to add `saucy` to the list of distributions
- Only one Postgres version can be installed / running. To be sure, remove any other versions of your system if your installation runs into problems at this step.

## Error on /tmp/cookbooks/build-essential/recipes/debian.rb

Make sure there are no 404'ing links in your repos.list

```
sudo apt-get update
```

should not give any 404 links.

## Other

- Your home folder can not already contain a `~/gitlab` folder! If that already exists, append a folder to the solo.json file, such as /dev (it should already exist). The `home` attribute should still point to your homefolder, independent of the GitLab installation folder.
- Unicorn.rb should have the correct path set to be able to start the server.
