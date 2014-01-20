### Development installation on metal (outside a Virtual Machine)

Running Gitlab directly on your machine can make it run considerably faster than inside a virtual machine, possibly making non reasonable wait times (10 minutes to start a test) reasonable (1.5 minutes).

### System choice

Before doing anything, you have to decide if you will install Gitlab on your existing system, or if you will install a new system dedicated to develop Gitlab.

#### Existing system

The advantage of installing an existing system is that you keep all your development programs and configurations untouched.

The downside is that there is a chance that your existing system setting (e.g. PPAs you added to Ubuntu, binaries you compiled from source) will be incompatible with those required by Gitlab, so if you want to play it safe and avoid hard to track problems, use a dedicated development system.

Furthermore, to install on an existing system you must be using a supported distribution. It is possible that things will work if you use a non-supported version of a supported system (e.g Ubuntu 13.10 instead of 12.04), but this adds even further to the risk of incompatibilities.

#### Dedicated system

The downside of installing a dedicated development system (possibly on the same HD as the existing one) is that it takes up a little time (~30 minutes if you know what your are doing) to install and disk space (30GB should be more than enough).

If your development environment is slow, however, it can be really worth it because of how much time you can gain later.

If you chose this option, do *not* create the `git` user at installation time: use the same username that you use on your existing system. This cookbook will create a correctly configured `git` user for you.

### Install

Once your a logged into the development system, the installation process is the same as a [production install](production.md), the only difference being what you put in the `/tmp/solo.json` configuration file which should instead be:

```bash
cat > /tmp/solo.json << EOF
{
    "gitlab": {
      "env": "development",
      "database_adapter": "mysql",
      "database_password": "a"
    },
    "mysql": {
      "server_root_password": "a"
    },
      "run_list": [
      "gitlab::default"
    ]
}
EOF
```

### Develop on dedicated system

If you chose to use a dedicated system, you have the following options of how to develop.

#### Git user on the development system

The advantage of running as the `git` user is that it is very easy to start up the server and run tests. Just do:

```bash
cd gitlab
bundle exec foreman start
firefox localhost:3000
```

And your server will be running.

Using the `git` user has the following downsides:

- you have to reinstall every development program that you use (editors, browsers, etc.)

- you have to find a way to copy all your configurations under your existing system's home to the git home.

    The problem is that it is not possible to use `mount` because the home folder is used by Gitlab.

    One option is to use git to store your configurations + a script that symlinks files to your home folder,
    such as done in [Zack Holam's dotfiles](https://github.com/dosire/dotfiles).

#### Non-Git user on the development system

The advantage of this option is that you can reuse your existing system's `/home` folder by mounting it.

Furthermore, there will be no interference between your home directory and the `git` home directory.

You do still have to reinstall all your development programs, and there is a small chance that they will interfere with those that Gitlab uses.

First make sure that your username on the development system is the same as the username on your existing system.

Next, mount your existing system's home directory on your development machine home by adding a line like the following line to your `/etc/fstab`:

    UUID=<existing_system_uuid> /home/<existing_username>    ext4    defaults    0    0

where you can find the `existing_system_uuid` via `sudo blkid` and `sudo lsblk -f`.

To be able to edit the Gitlab files easily, use `bindfs` to bind the Gitlab folder to your home directory under a different username.

To do that automatically on every startup on Ubuntu use the following:

```bash
sudo apt-get install bindfs
sudo tee /etc/init/bindfs-gitlab.conf << EOF
mkdir -p ~/gitlab
description	"Bindfs mount gitlab for development user."

start on stopping mountall

script
    bindfs -u $USER -g $USER --create-for-user=git --create-for-group=git /home/git/gitlab /home/$USER/gitlab
end script
EOF
```

From now on your `~/gitlab` directory will be synced with the `git` user `~/gitlab` directory, but it will seem to you that you are the owner of the files.

Also, if your create any files, the `git` user will still see them with owner `git`.

To be able to run graphical programs while logged in as `git` you need to do as your development user:

```bash
xhost +
```

which you can add to your `.~/profile`.

This will enable your to see letter opener emails or Capybara `save_and_open_page` if your tests fail.

Whenever you start a new shell to develop, do `sudo su git`, and you are ready for the usual

```bash
cd ~/gitlab
bundle exec foreman start
firefox localhost:3000
```
