### Development installation on metal (outside a Virtual Machine)

Running Gitlab directly on your machine can make it run considerably faster than inside a virtual machine, possibly making non reasonable wait times (10 minutes to start a tests) reasonable (1.5 minutes).

The only downside is that it requires you to install a new OS in your hard disk, but if your development environment is slow, it can be really worth it because of how much time you can gain.

First install a new OS on your machine, possibly alongside an existing one. 30GB should be more than enough to develop. We will call this new system the *development* system, and your old system the *main* system

Do *not* create the `git` user just yet: use the same username that you use on your main system. This cookbook will create a correctly configured `git` user for your.

Once your a logged into the new system, the installation process is the same as a [production install](production.md), the only difference being what you put in the `/tmp/solo.json` configuration file which should instead be:

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

### Developing

Once installed, there are a few strategies you can use to develop conveniently on the development system.

#### Git user on the development system

The advantage of this option is that it is very easy to start up the server and run tests. Just do:

```bash
cd gitlab
bundle exec foreman start
firefox localhost:3000
```

And your server will be running.

Using the git user has the following downsides:

- you have to reinstall every development program that you use (editors, browsers, etc.)

- you have to find a way to copy all your configurations under your main computer's `home` to the git home.

    The problem is that it is not possible to use `mount` because the home folder is used by Gitlab.

    One option is to use git to store your configurations + a script that symlinks files to your home folder,
    such as done in [this repo](https://github.com/dosire/dotfiles).

#### Non-Git user on the development system

The advantage of this option is that you can reuse your main system's `/home` folder by mounting it.

Furthermore, there will be no interference between your home directory and the `git` home directory.

You do still have to reinstall all your development programs, and there is a small chance that they will interfere with those that Gitlab users.

First make sure that your username is the same as the username on your main system.

Next, mount your main system's home directory on your development machine home by adding a line like the following line to your `/etc/fstab`:

    UUID=<main_system_uuid> /home/<main_username>    ext4    defaults    0    0

where you can find the `main_system_uuid` via `sudo blkid` and `sudo lsblk -f`.

To be able to edit the gitlab files easily, use `bindfs` to bind the gitlab folder to your home dir under a different username.

To do that automatically on every startup on Ubuntu use the following:

```bash
sudo apt-get install bindfs
sudo tee /etc/init/bindfs-gitlab.conf << EOF
mkdir -p ~/gitlab
description	"Bindfs mount gitlab for main user."

start on stopping mountall

script
    bindfs -u $USER -g $USER --create-for-user=git --create-for-group=git /home/git/gitlab /home/$USER/gitlab
end script
EOF
```

From now on your `~/gitlab` directory will be synced with the `git` user `~/gitlab` directory, but it will seem to you that you are the owner of the files.

Also, if your create any files, the `git` user will still see them with owner `git`.

To be able to run graphical programs while logged in as `git` you need to do as your main user:

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
