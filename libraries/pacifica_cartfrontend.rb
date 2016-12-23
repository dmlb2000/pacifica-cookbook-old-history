module PacificaCookbook
  require_relative 'pacifica_base'
  class PacificaCartFrontend < PacificaBase
    property :name, String, name_property: true
    property :git_opts, Hash, default: {
      repository: 'https://github.com/EMSL-MSC/pacifica-cartd.git'
    }
    property :directory_opts, Hash, default: lazy {
      {
        path: "#{prefix_dir}/cartdata",
        recursive: true
      }
    }
    property :service_opts, Hash, default: lazy {
      {
        exec_start: "#{virtualenv_dir}/bin/python #{source_dir}/cartserver.py --port 8081 --address 0.0.0.0",
        environment: {
          VOLUME_PATH: "#{prefix_dir}/cartdata",
          LRU_BUFFER_TIME: 0
        }
      }
    }
    resource_name :pacifica_cartfrontend
  end
end
