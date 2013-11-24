### Amazon Web Services

#### Requirements
* [VirtualBox](https://www.virtualbox.org)
* [Vagrant 1.3.x](http://vagrantup.com)

**Note:** Make sure to use Vagrant v1.3.x. Do not install via rubygems.org as there exists an old gem
which will probably cause errors. Instead, go to [Vagrant download page](http://downloads.vagrantup.com/) and install a version >= `1.3.x`.

### Vagrant Plugin

* [vagrant-berkshelf](https://github.com/RiotGames/vagrant-berkshelf)
* [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus)
* [vagrant-aws](https://github.com/mitchellh/vagrant-aws)

Creates an AWS instance.

```bash
gem install berkshelf
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-aws
vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git ./gitlab
cd ./gitlab/
cp ./example/Vagrantfile_aws ./Vagrantfile
```
Fill in the AWS credentials under the aws section in Vagrantfile and then run:

```bash
vagrant up --provider=aws
```

HostName setting.

```bash
vagrant ssh-config | awk '/HostName/ {print $2}'
editor ./Vagrantfile
vagrant provision
```
