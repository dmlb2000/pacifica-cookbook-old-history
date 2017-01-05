# pacifica cookbook module
module PacificaCookbook
  require_relative 'pacifica_base'
  # installs and configures pacifica ingest frontend wsgi
  class PacificaIngestFrontend < PacificaBase
    property :name, String, name_property: true
    property :git_opts, Hash, default: {
      repository: 'https://github.com/EMSL-MSC/pacifica-ingest.git',
    }
    property :directory_opts, Hash, default: lazy {
      {
        path: "#{prefix_dir}/ingestdata",
        recursive: true,
      }
    }
    property :service_opts, Hash, default: lazy {
      {
        environment: {
          VOLUME_PATH: "#{prefix_dir}/cartdata",
          MYSQL_ENV_MYSQL_DATABASE: 'ingest',
          MYSQL_ENV_MYSQL_PASSWORD: 'ingest',
          MYSQL_ENV_MYSQL_USER: 'ingest',
        },
      }
    }
    property :run_command, String, default: lazy {
      "#{virtualenv_dir}/bin/uwsgi --http-socket :8066 --wsgi-file #{source_dir}/IngestServer.py"
    }
    resource_name :pacifica_ingestfrontend
  end
end
