Development setup on a virtual machine with Vagrant
===============================

Sets up a local development environment for GitLab using a Vagrant virtual machine.

After a successful installation, you will have a complete, self-contained virtual machine running GitLab. The database will also be seeded with sample content.

**IMPORTANT:** This virtual machine has been configured for ease of local development. Security of the resulting environment is deliberately lax. Do not use this method to prepare a production machine!

Requirements
------------

* [Ruby](https://www.ruby-lang.org/en/) 2.0.0 or higher and [Rubygems](http://rubygems.org/)
* [Bundler](http://bundler.io)
* [Git](http://git-scm.com)
* [VirtualBox](https://www.virtualbox.org) 4.3.x
* [Vagrant](http://vagrantup.com) 1.6.x
* NFS packages. Already installed if you are using Mac OS X, and not necessary if you are using Windows. On Linux:

    ```
    sudo apt-get install nfs-kernel-server nfs-common portmap
    ```

* Administrative, sudo, or root privileges on your computer
* Some patience :smiley:

On OS X you can also choose to use the [Vagrant VMware provider](http://docs.vagrantup.com/v2/vmware/) instead of VirtualBox.

**Note:** Make sure to use Vagrant v1.6.x. Do not install via rubygems.org. Instead, grab the latest version from http://downloads.vagrantup.com/.

Installation
------------

First, install all necessary dependencies listed above, then clone the cookbook repository:

    git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git
    cd cookbook-gitlab

And install all required gems and plugins:

    vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1
    vagrant plugin install vagrant-omnibus
    vagrant plugin install vagrant-bindfs
    bundle install

Finally, you should be able to start and configure the Vagrant box. This operation can take a long time, up to an hour depending on your computer's performance and internet connection.

    vagrant up

You will likely encounter errors during the initial set up provisioning process. This is due to differences between various OS and different machines this is being ran on. It is important to keep rerunning `vagrant provision` until it does not report any errors and returns you to the command prompt. See the Troubleshooting section for help.

By default the VM uses 1.5GB of memory and 2 CPU cores. If you want to use more memory or cores you can use the GITLAB_VAGRANT_MEMORY and GITLAB_VAGRANT_CORES environment variables:

    GITLAB_VAGRANT_MEMORY=2048 GITLAB_VAGRANT_CORES=4 vagrant up

**Note:**
You can't run a vagrant project on an encrypted partition (ie. it won't work if your home directory is encrypted). You can still run the VM if you are using products like Apple FileVault 2 or Microsoft Bitlocker to encrypt your system drive.

You'll be asked for your administrative account password to set up NFS shares. If the NFS mount succeeds, the `cookbook-gitlab/vagrant` directory will be shared between your local computer and the Vagrant box. Any chnages made to files locally will be available to the GitLab server in the VM.

### Starting GitLab ###

Once the Vagrant box is up and running, you'll need to log in with

    vagrant ssh

Then start GitLab with:

    gitlab

or with the full command:

    cd /gitlab/gitlab; bundle exec foreman start

The first time GitLab is started, it may take up to five minutes to begin responding to web requests.

You can stop the service any time with the `Ctrl + C` key combination.

### Running tests ###

Once everything is done you can verify the installation by running tests. This may take a _very_ long time:

    vagrant ssh
    bundle exec rake gitlab:test

Troubleshooting
---------------

If `vagrant up` fails or reports any errors, try again with `vagrant provision`. Try this a couple of times. Installation errors often resolve themselves. You might also try disabling any virus protection software or third-party firewalls running on the host machine.

If you run into port conflicts between the guest and host, you can either:

  1. Shut down any services on your computer currently listening on ports 3000 or 8888.
  2. Disable Vagrant port forwarding using `GITLAB_VAGRANT_FORWARD=0 vagrant up`

If you are using a firewall on the host machine, it should allow NFS related traffic, otherwise you might encouter NFS mounting errors during vagrant up like:

    mount.nfs: mount to NFS server '.../cookbook-gitlab/vagrant' failed: timed out, giving up

If you get errors about installing the pg gem, or missing make. Make sure to install the build-essential package.

    vagrant ssh
    sudo apt-get install build-essential

After starting the server, you may not be able to log in to the GitLab web interface or you might see ActiveRecord errors. If this happens, the database may not have been seeded properly. Try logging in to the VM and running the tasks manually:

    vagrant ssh
    cd /gitlab/gitlab
    bundle exec rake db:schema:load db:migrate db:seed_fu

Accessing Gitlab
----------------

Once installed and started, you'll be able to access GitLab in a browser from your local machine. You can visit it at the following address:

  * http://localhost:3000

If you started the VM with the `GITLAB_VAGRANT_FORWARD=0` option, you'll need to use the local IP address. Point your bowser to:

  * http://192.168.3.4:3000

Please login with root / 5iveL!fe

Sometimes, when making changes to application code, you will need to restart GitLab to see the results:

    Ctrl + C
    gitlab

### Updating GitLab ###

GitLab is _not_ updated when you rebuild your virtual machine with the following command:

    vagrant destroy && vagrant up

You must update it yourself by going to the `vagrant/gitlab` subdirectory in the repo and pulling the latest changes:

    cd vagrant/gitlab && git pull

You can also simply delete the vagrant/gitlab, vagrant/gitlab-shell, vagrant/gitlab-satellites, and vagrant/repositories directories to grab a fresh copy of the project.

    vagrant halt
    rm -rf vagrant/gitlab vagrant/gitlab-shell vagrant/gitlab-satellites vagrant/repositories
    vagrant destroy && vagrant up

Virtual Machine Management
--------------------------

When you are finished working in the Vagrant VM, logout with `exit` and suspend the virtual machine

    vagrant suspend

then, resume to start developing again

    vagrant resume

Run

    vagrant halt

to shutdown the virtual machine, and

    vagrant up

to boot it again. If you want to run the provisioning scripts again, use the provision command.

    vagrant up && vagrant provision

You can find out the state of a virtual machine anytime by invoking

    vagrant status

Finally, to completely wipe the virtual machine from the disk **destroying all its contents**:

    vagrant destroy # DANGER: deletes all virtual machine files

Information
-----------

* Virtual Machine IP: 192.168.3.4
* GitLab web interface running at: http://localhost:3000/ or http://192.168.3.4:3000/
* Virtual Machine user/password: vagrant/vagrant
* GitLab webapp user/password: root/5iveL!fe
* PostgreSQL user/password: git/datapass
* MySQL user/password: git/datapass
* MySQL root password: rootpass
