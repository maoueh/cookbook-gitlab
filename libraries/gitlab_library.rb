class Chef
  class Recipe
    ##
    # Cookbook gitlab library module
    #
    # This mainly offers some common bits more easily defined as library functions
    #
    class GitLab
      def self.bundle_exec(node, arguments)
        segments = []

        segments << "PATH=#{env_path(node)}"
        segments << "RAILS_ENV=production"

        segments << "bundle exec"
        segments << arguments

        segments.join(" ")
      end

      def self.bundle_exec_rake(node, arguments)
        bundle_exec(node, "rake " + arguments)
      end

      def self.bundle_install(node)
        segments = []

        segments << "SSL_CERT_FILE=/opt/local/etc/certs/cacert.pem"
        segments << "PATH=#{env_path(node)}"

        segments << "bundle install"
        segments << "--path=.bundle"
        segments << "--deployment"

        case node['gitlab']['database_adapter']
        when "mysql"
          segments << "--without development test postgres"
        when "postgresql"
          segments << "--without development test mysql"
        end

        segments.join(" ")
      end

      def self.env_path(node)
        segments = []

        if node['gitlab']['database_adapter'] == "postgresql"
          segments << node['gitlab']['postgresql']['configuration_dir'] if node['gitlab']['postgresql']['configuration_dir']
        end

        segments << "/usr/local/bin:$PATH"

        segments.join(":")
      end

      def self.install?(recipe)
        resource_ran?(recipe, "mysql_database[gitlabhq_production]") ||
        resource_ran?(recipe, "postgresql_database[gitlabhq_production]") ||
        recipe.node['gitlab']['force_install'] == true
      end

      def self.upgrade?(recipe)
        resource_ran?(recipe, "git[clone gitlabhq source]") ||
        recipe.node['gitlab']['force_upgrade'] == true
      end

      def self.redis_sed_exec(node)
        instance_hash = node['redisio']['servers'][0].to_hash()
        defaults_hash = node['redisio']['default_settings'].to_hash()
        current_hash = defaults_hash.merge(instance_hash)

        server_name = current_hash['name'] || current_hash['port']
        bin_path = node['redisio']['install_dir'] ? "#{node['redisio']['install_dir']}/bin" : "/usr/local/bin"
        config_path = current_hash['configdir']

        user = current_hash['user']
        group = node['gitlab']['group']

        case node['platform']
        when 'centos'
          old_exec = "EXEC=\"runuser #{user} -c.*\""
          new_exec = "EXEC=\"runuser #{user} -g #{group} -c \\\\\"#{bin_path}/redis-server #{config_path}/${REDISNAME}.conf\\\\\"\""
        else
          old_exec = "EXEC=\"su -s.*\""
          new_exec = "EXEC=\"sudo -u #{user} -g #{group} #{bin_path}/redis-server #{config_path}/${REDISNAME}.conf\""
        end

        "sed -i s#'#{old_exec}'#'#{new_exec}'# /etc/init.d/redis#{server_name}"
      end

      def self.required_services(node)
        required_services = []

        required_services << "redis#{node['gitlab']['redis_port']}"

        case node['gitlab']['database_adapter']
        when "mysql"
          required_services << "mysql-#{node['mysql']['server']['instance']}"
        when "postgresql"
          required_services << node['postgresql']['server']['service_name']
        end

        required_services
      end

      private

      def self.resource_ran?(recipe, resource)
        recipe.resources(resource).updated_by_last_action?
      rescue Chef::Exceptions::ResourceNotFound
        false
      end
    end
  end
end