# pacifica cookbook module
module PacificaCookbook
  require_relative 'pacifica_base'
  # Manages the Pacifica archive interface service
  class PacificaArchiveInterface < PacificaBase
    property :name, String, name_property: true
    property :git_opts, Hash, default: {
      repository: 'https://github.com/EMSL-MSC/pacifica-archiveinterface.git'
    }
    property :service_opts, Hash, default: lazy {
      { exec_start: "#{virtualenv_dir}/bin/python "\
                    "#{source_dir}/scripts/archiveinterfaceserver.py" }
    }
    resource_name :pacifica_archiveinterface
  end
end
