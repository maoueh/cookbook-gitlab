#!/bin/sh
if [ ! -f /etc/motd_vagrant ]; then
  echo 'You are now logged in as the git user that runs GitLab, to get sudo privileges please exit to become the vagrant user' >> /etc/motd_vagrant
fi

if [ ! -f /etc/motd_git ]; then
  echo 'You are now logged in as the vagrant user' >> /etc/motd_git
fi

if [ ! -f /etc/profile.d/message.sh ]; then
  echo '#!/bin/sh' >> /etc/profile.d/message.sh
  echo 'cat /etc/motd_$USER' >> /etc/profile.d/message.sh
fi

cat /home/vagrant/.bashrc | grep 'sudo su - git' || echo 'sudo su - git' >> /home/vagrant/.bashrc
