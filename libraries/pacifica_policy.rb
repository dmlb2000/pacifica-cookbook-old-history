# pacifica cookbook module
module PacificaCookbook
  require_relative 'pacifica_base'
  # install and configure pacifica policy service
  class PacificaPolicy < PacificaBase
    property :name, String, name_property: true
    property :git_opts, Hash, default: {
      repository: 'https://github.com/EMSL-MSC/pacifica-policy.git',
    }
    property :service_opts, Hash, default: lazy {
      {
        exec_start: "#{virtualenv_dir}/bin/python PolicyServer.py",
      }
    }
    resource_name :pacifica_policy
  end
end
