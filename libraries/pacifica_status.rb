# pacifica cookbook module
module PacificaCookbook
  require_relative 'pacifica_base_php'
  # installs and configures pacifica cart frontend wsgi
  class PacificaStatus < PacificaBasePhp
    property :name, String, name_property: true
    property :git_opts, Hash, default: {
      repository: 'https://github.com/EMSL-MSC/pacifica-upload-status.git'
    }
    resource_name :pacifica_status
  end
end
