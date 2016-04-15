name             'gitlab'
maintainer       'Matthieu Vachon'
maintainer_email 'matthieu.o.vachon@gmail.com'
license          'MIT'
description      'Installs/Configures GitLab'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.8.7'

source_url       'https://github.com/maoueh/cookbook-gitlab'
issues_url       'https://github.com/maoueh/cookbook-gitlab/issues'

recipe 'gitlab::default', 'Default installation, includes all required recipes'

depends 'apt', '~> 2.6'
depends 'build-essential', '~> 2.2'
depends 'database', '~> 4.0'
depends 'git', '~> 4.0'
depends 'golang', '~> 1.7'
depends 'magic_shell', '~> 1.0'
depends 'monit', '~> 1.4'
depends 'mysql', '~> 6.1'
depends 'mysql2_chef_gem', '~> 1.0'
depends 'postgresql', '~> 3.4'
depends 'redisio', '~> 2.3'
depends 'ruby_build', '~> 0.8'
depends 'selinux', '~> 0.8'
depends 'yum-epel', '~> 0.6'

%w{ debian ubuntu centos }.each do |os|
  supports os
end
