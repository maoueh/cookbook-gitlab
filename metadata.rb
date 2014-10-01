name             'gitlab'
maintainer       'Marin Jankovski'
maintainer_email 'marin@gitlab.com'
license          'MIT'
description      'Installs/Configures GitLab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.7.3'

recipe "gitlab::default", "Installation"

depends 'apt', '2.3.8'
depends 'build-essential', '2.0.6'
depends 'database', '2.1.6'
depends 'magic_shell', '0.3.2'
depends 'monit', '1.4.0'
depends 'mysql', '5.1.12'
depends 'phantomjs', '1.0.3'
depends 'postfix', '3.1.8'
depends 'postgresql', '3.4.1'
depends 'redisio', '1.7.1'
depends 'ruby_build', '0.8.0'
depends 'yum-epel', '0.3.6'

%w{ debian ubuntu centos }.each do |os|
  supports os
end
