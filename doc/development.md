### Development

* [VirtualBox](https://www.virtualbox.org)
* the NFS packages. Already there if you are using Mac OS, and
  not necessary if you are using Windows. On Linux:

```bash
sudo apt-get install nfs-kernel-server nfs-common portmap
```
    On OS X you can also choose to use [the (commercial) Vagrant VMware Fusion plugin](http://www.vagrantup.com/vmware) instead of VirtualBox.

* some patience :)

#### Vagrant
`Vagrantfile` already contains the correct attributes so in order use this cookbook in a development environment following steps are needed:

1. Check if you have a gem version of Vagrant installed:

```bash
gem list vagrant
```

If it lists a version of vagrant, remove it with:

```bash
gem uninstall vagrant
```

Next steps are:

```bash
gem install berkshelf
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git
cd ./cookbook-gitlab
vagrant up
```

By default the VM uses 1.5GB of memory and 2 CPU cores. If you want to use more memory or cores you can use the GITLAB_VAGRANT_MEMORY and GITLAB_VAGRANT_CORES environment variables:

```bash
GITLAB_VAGRANT_MEMORY=2048 GITLAB_VAGRANT_CORES=4 vagrant up
```

**Note:**
You can't use a vagrant project on an encrypted partition (ie. it won't work if your home directory is encrypted).

You'll be asked for your password to set up NFS shares.

Once everything is done you can log into the virtual machine to run tests:

```bash
vagrant ssh
sudo su git
cd /home/git/gitlab/
bundle exec rake gitlab:test
```

Start the Gitlab app:

```bash
cd /home/git/gitlab/
bundle exec foreman start
```

You should also configure your own remote since by default it's going to grab
gitlab's master branch.

```bash
git remote add mine git://github.com/me/gitlabhq.git
# or if you prefer set up your origin as your own repository
git remote set-url origin git://github.com/me/gitlabhq.git
```

##### Virtual Machine Management

When done just log out with `^D` and suspend the virtual machine

```bash
vagrant suspend
```

then, resume to hack again

```bash
vagrant resume
```

Run

```bash
vagrant halt
```

to shutdown the virtual machine, and

```bash
vagrant up
```

to boot it again.

You can find out the state of a virtual machine anytime by invoking

```bash
vagrant status
```

Finally, to completely wipe the virtual machine from the disk **destroying all its contents**:

```bash
vagrant destroy # DANGER: all is gone
```

#### Done!

`http://0.0.0.0:3000/` or your server for your first GitLab login.

```
admin@local.host
5iveL!fe
```

#### OpenLdap

If you need to setup OpenLDAP in order to test the functionality you can use the [basic OpenLDAP setup guide](doc/open_LDAP.md)

#### Updating

The gitlabhq version is _not_ updated when you rebuild your virtual machine with the following command:

```bash
vagrant destroy && vagrant up
```

You must update it yourself by going to the gitlabhq subdirectory in the gitlab-vagrant-vm repo and pulling the latest changes:

```bash
cd gitlabhq && git pull --ff origin master
```

A bit of background on why this is needed. When you run 'vagrant up' there is a checkout action in the recipe that points to [gitlabhq repo](https://github.com/gitlabhq/gitlabhq). You won't see any difference when running 'git status' in the cookbook-gitlab repo because gitlabhq/ is in the [.gitignore](https://gitlab.com/gitlab-org/cookbook-gitlab/blob/master/.gitignore). You can update the gitlabhq repo yourself or remove the gitlabhq directory so the repo is checked out again.
