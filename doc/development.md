# Development setup on the host operating system with Chef Solo

To develop GitLab we install it directly on your machine (it runs on metal).
A metal install is much faster than the old deprecated installation method inside a virtual machine where a single page load could take minutes.
A disadvantage of a metal install that you might run into conflicts because some programs are already on your system.
*Please read the whole document including the troubleshooting and limitations section before starting the setup as it can alter your system installation.*

This guide is tested and confirmed working on:

* Ubuntu 13.10
* Ubuntu 14.04
* Please send merge request to add other OS's you've tested it on.

The first step is to create a solo.json file.

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

For development it is convenient to setup GitLab under your existing user account.
In `/tmp/solo.json` configuration file, replace the occurences of `USER` and `USERGROUP` with your user details, this can be done with:

```bash
sed -i s/USERGROUP/$(groups | awk '{print $1;}')/ /tmp/solo.json
sed -i s/USER/$(whoami)/ /tmp/solo.json
```

If you don't have ruby installed on your dev machine, you can let the cookbook do it for you by setting compile_ruby to true in `/tmp/solo.json`, this can be done with:
```bash
which ruby
if [ "$?" -ne "0" ]
then
    sed -i s/\"compile_ruby\"\:\ false/\"compile_ruby\"\:\ true/ /tmp/solo.json
fi
```

You can alter the paths to place the code somewhere convenient but by default it places everything under home directory of `USER` which is recommended.

Add the required development tools for your operating system (we need git to clone the cookbook, a newer git version will be compiled using the cookbook):

```bash
distro="$(cat /etc/issue | awk ''NR==1'{ print $1 }')"
case "$distro" in
  Ubuntu)
    sudo apt-get update
    sudo apt-get install -y build-essential autoconf git curl
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

After installing GitLab using the cookbook navigate to the Rails application directory:

```bash
cd /home/USER/gitlab
```

and follow [the readme instructions to run it in development mode](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/README.md#run-in-development-mode).

*Note* Pulling and pushing over SSH won't work on this metal setup but you can still clone and push using http.

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

## Can have only one PostgreSQL version installed

Only one PostgreSQL version can be installed / running. To be sure, remove any other versions of your system if your installation runs into problems at this step.

## Error on /tmp/cookbooks/build-essential/recipes/debian.rb

Make sure there are no 404'ing links in your repos.list since they cause a failing exit code and the cookbook run to fail. The command below should not give any 404 links:

```
sudo apt-get update
```

## No gitlab folder in your home directory

Your home folder can not already contain a `~/gitlab` folder! If that already exists, append a folder to the solo.json file, such as /dev (it should already exist).
The `home` attribute should still point to your homefolder, independent of the GitLab installation folder.

## Unicorn should have the correct path

Unicorn.rb should have the correct path set to be able to start the server.

## Ruby version manager conflict

Ensure you ruby version manager points to a recent version of Ruby (2.0+) and that chef solo was run with that version in its path.

## Failed cookbook run / missing database

If the cookbook run fails halfway you might be stuck with a half filled database, even if the next run is successfull.
Please use the commands below to get to a complete db:

```bash
bundle exec rake db:migrate
bundle exec rake db:seed_fu
```
