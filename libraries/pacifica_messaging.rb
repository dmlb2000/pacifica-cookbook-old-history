module PacificaCookbook
  require_relative 'pacifica_base'
  class PacificaMessaging < PacificaBase
    resource_name :pacifica_messaging
    default_action :create

    action :create do
      host_list.each do |host|
        name = 'messaging'
        repo = 'rabbitmq'
        port = 5672
        image_opts = image_template repo, host
        docker_image "pacifica_#{name}_#{host}" do
          image_opts.merge(image_properties).each do |attr, value|
            send(attr, value)
          end
        end
        container_opts = container_template repo, 5672, host
        docker_container "pacifica_#{name}_#{host}" do
          container_opts.merge(container_properties).each do |attr, value|
            send(attr, value)
          end
        end
      end
    end
  end
end
