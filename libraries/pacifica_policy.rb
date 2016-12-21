module PacificaCookbook
  require_relative 'pacifica_base'
  class PacificaPolicy < PacificaBase
    resource_name :pacifica_policy
    default_action :create

    action :create do
      host_list.each do |host|
        name = 'policy'
        port = 8181
        image_opts = pacifica_image_template name, host
        docker_image "pacifica_#{name}_#{host}" do
          image_opts.merge(image_properties).each do |attr, value|
            send(attr, value)
          end
        end
        container_opts = pacifica_container_template name, port, host
        docker_container "pacifica_#{name}_#{host}" do
          container_opts.merge(container_properties).each do |attr, value|
            send(attr, value)
          end
        end
      end
    end
  end
end
