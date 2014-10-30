name             'gitlab'
maintainer       'Marin Jankovski'
maintainer_email 'marin@gitlab.com'
license          'MIT'
description      'Installs/Configures GitLab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.7.4'

recipe "gitlab::default", "Installation"

depends 'apt', '~> 2.3'
depends 'build-essential', '~> 2.0'
depends 'database', '~> 2.1'
depends 'magic_shell', '~> 0.3'
depends 'monit', '~> 1.4'
depends 'mysql', '~> 5.1'
depends 'phantomjs', '~> 1.0'
depends 'postfix', '~> 3.1'
depends 'postgresql', '~> 3.4'
depends 'redisio', '~> 1.7'
depends 'ruby_build', '~> 0.8'
depends 'yum-epel', '~> 0.3'

%w{ debian ubuntu centos }.each do |os|
  supports os
end
