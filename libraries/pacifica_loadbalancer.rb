module PacificaCookbook
  class PacificaLoadBalancer < PacificaBase
    resource_name :pacifica_loadbalancer
    default_action :create
    property :endpoint_list, Array, default: lazy { default_endpoint_list }
    property :listen_port, Integer, default: 80
    property :dest_port, Integer, default: 8080
    property :path, String, default: '/'

    def default_endpoint_list
      [node['ipaddress']]
    end

    def build_env_from_attr
      ret = ["#{name}_PATH".upcase + "=#{path}"]
      ret << "#{name}_REMOTE_PORT".upcase + "=#{dest_port}"
      endpoint_list.each_index do |x|
        ret << "#{name}_#{x}_port_#{dest_port}_tcp_addr".upcase + "=#{endpoint_list[x]}"
      end
      ret
    end

    action :create do
      host_list.each do |host|
        repo = 'jasonwyatt/nginx-loadbalancer'
        image_opts = image_template repo, host
        docker_image "pacifica_#{name}_lb_#{host}" do
          image_opts.merge(image_properties).each do |attr, value|
            send(attr, value)
          end
        end
        container_opts = container_template repo, listen_port, host
        container_opts['env'] = build_env_from_attr
        docker_container "pacifica_#{name}_lb_#{host}" do
          container_opts.merge(container_properties).each do |attr, value|
            send(attr, value)
          end
        end
      end
    end
  end
end

