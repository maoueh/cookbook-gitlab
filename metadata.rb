name             'gitlab'
maintainer       'Matthieu Vachon'
maintainer_email 'matthieu.o.vachon@gmail.com'
license          'MIT'
description      'Installs/Configures GitLab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.7.6'

recipe "gitlab::default", "Installation"

depends 'apt', '~> 2.6'
depends 'build-essential', '~> 2.1'
depends 'database', '~> 3.0'
depends 'git', '~> 4.0'
depends 'magic_shell', '~> 1.0'
depends 'monit', '~> 1.4'
depends 'mysql', '~> 6.0'
depends 'phantomjs', '~> 1.0'
depends 'postfix', '~> 3.6'
depends 'postgresql', '~> 3.4'
depends 'redisio', '~> 2.2'
depends 'ruby_build', '~> 0.8'
depends 'selinux', '~> 0.8'
depends 'yum-epel', '~> 0.6'

%w{ debian ubuntu centos }.each do |os|
  supports os
end
