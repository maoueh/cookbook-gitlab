require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  # Specify a default static file cache path (not a problem since resoucres are not executed)
  config.file_cache_path = "/var/chef/cache"

  # Specify the Chef log_level (default: :warn)
  config.log_level = :error
end
