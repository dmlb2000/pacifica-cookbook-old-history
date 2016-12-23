module PacificaCookbook
  require_relative 'pacifica_base'
  class PacificaCartBackend < PacificaBase
    property :name, String, name_property: true
    property :git_opts, Hash, default: {
      repository: 'https://github.com/EMSL-MSC/pacifica-cartd.git'
    }
    property :service_opts, Hash, default: lazy {
      {
        exec_start: "#{virtualenv_dir}/bin/python -m celery -A cart worker -l info",
        environment: {
          VOLUME_PATH: "#{prefix_dir}/cartdata/",
          LRU_BUFFER_TIME: 0,
          MYSQL_ENV_MYSQL_PASSWORD: 'cart',
          MYSQL_ENV_MYSQL_USER: 'cart'
        }
      }
    }
    resource_name :pacifica_cartbackend
  end
end
