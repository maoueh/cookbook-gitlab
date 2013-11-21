#### Amazon Web Services

Creates an AWS instance.

```bash
$ gem install berkshelf
$ vagrant plugin install vagrant-berkshelf
$ vagrant plugin install vagrant-omnibus
$ vagrant plugin install vagrant-aws
$ vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
$ git clone git://github.com/gitlabhq/cookbook-gitlab ./gitlab
$ cd ./gitlab/
$ cp ./example/Vagrantfile_aws ./Vagrantfile
```
Fill in the AWS credentials under the aws section in Vagrantfile and then run:

```bash
$ vagrant up --provider=aws
```

HostName setting.

```bash
$ vagrant ssh-config | awk '/HostName/ {print $2}'
$ editor ./Vagrantfile
$ vagrant provision
```

#### AWS OpsWorks

* Create a custom layer or use a predefined `Rails app server` layer.
* Edit the layer
* Under `Custom Chef Recipes` supply the url to the cookbook repository
* Under `Setup` write `gitlab::setup` and press the + sign to add
* Under `Deploy` write `gitlab::deploy` and press the + sign to add
* Save changes made to the layer (Scroll to the bottom of the page for the Save button)
* Go to Instances
* Create a new instance(or use an existing one) and add the previously edited layer
