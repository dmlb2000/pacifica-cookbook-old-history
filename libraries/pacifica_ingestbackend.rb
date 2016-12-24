# pacifica cookbook module
module PacificaCookbook
  require_relative 'pacifica_base'
  # installs and configures pacifica ingest backend celery
  class PacificaIngestBackend < PacificaBase
    property :name, String, name_property: true
    property :git_opts, Hash, default: {
      repository: 'https://github.com/EMSL-MSC/pacifica-ingest.git',
    }
    property :service_opts, Hash, default: lazy {
      {
        exec_start: "#{virtualenv_dir}/bin/python -m celery "\
                    '-A ingest.backend worker -l info',
        environment: {
          VOLUME_PATH: "#{prefix_dir}/ingestdata",
          MYSQL_ENV_MYSQL_PASSWORD: 'ingest',
          MYSQL_ENV_MYSQL_USER: 'ingest',
        },
      }
    }
    resource_name :pacifica_ingestbackend
  end
end
