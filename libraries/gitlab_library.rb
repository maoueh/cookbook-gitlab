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
        segments << "--no-ri"
        segments << "--no-rdoc"

        case node['gitlab']['database_adapter']
        when "mysql"
          segments << "--without development test postgresql"
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
    end
  end
end