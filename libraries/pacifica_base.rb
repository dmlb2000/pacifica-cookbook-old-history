module PacificaCookbook
  class PacificaBase < ChefCompat::Resource

    def default_host_list
      return [nil] unless ENV['DOCKER_HOST']
      [ENV['DOCKER_HOST']]
    end

    def pacifica_container_template(name, port, host)
      container_template "pacifica/#{name}", port, host
    end

    def container_template(repo, port, host)
      {
        host: host,
        repo: repo,
        tag: tag,
        port: "#{port}:#{port}",
        kill_after: 10
      }
    end

    def pacifica_image_template(name, host)
      image_template "pacifica/#{name}", host
    end

    def image_template(repo, host)
      {
        host: host,
        repo: repo,
        tag: tag
      }
    end

    property :host_list, Array, default: lazy { default_host_list }
    property :tag, String, default: 'latest'
    property :image_properties, Hash, default: {}
    property :container_properties, Hash, default: {}
  end
end
