require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  # Specify a default static file cache path (not a problem since resoucres are not executed)
  config.file_cache_path = '/var/chef/cache'

  # Specify the Chef log_level (default: :warn)
  config.log_level = :error
end

def supported_platforms
  {
    'centos' => ['6.5'],
    'ubuntu' => ['14.04']
  }
end

def env_path(node)
  segments = []

  if node['gitlab']['database_adapter'] == 'postgresql'
    segments << node['gitlab']['postgresql']['configuration_dir'] if node['gitlab']['postgresql']['configuration_dir']
  end

  segments << '/usr/local/bin:$PATH'

  segments.join(':')
end

def nginx_config(platform)
  case platform
  when 'centos'
    '/etc/nginx/conf.d/gitlab.conf'
  when 'ubuntu'
    '/etc/nginx/sites-available/gitlab'
  else
    fail "Platform #{platform} not tested"
  end
end
