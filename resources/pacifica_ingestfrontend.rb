# require_relative 'pacifica_base'
# installs and configures pacifica ingest frontend wsgi
resource_name :pacifica_ingestfrontend

property :git_opts, Hash, default: {
  repository: 'https://github.com/EMSL-MSC/pacifica-ingest.git'
}
property :directory_opts, Hash, default: lazy {
  {
    path: "#{prefix_dir}/ingestdata",
    recursive: true
  }
}
property :service_opts, Hash, default: lazy {
  {
    environment: {
      VOLUME_PATH: "#{prefix_dir}/cartdata",
      MYSQL_ENV_MYSQL_DATABASE: 'ingest',
      MYSQL_ENV_MYSQL_PASSWORD: 'ingest',
      MYSQL_ENV_MYSQL_USER: 'ingest'
    }
  }
}
property :wsgi_file, String, default: 'IngestServer.py'
property :port, String, default: 8066

# action_class do
#   extend PacificaCookbook::PacificaHelpers::Directories
# end

default_action :create

action :create do
  extend PacificaCookbook::PacificaHelpers::Directories
  pacifica_base new_resource.name do
    git_opts new_resource.git_opts
    directory_opts new_resource.directory_opts
    service_opts new_resource.service_opts
    wsgi_file new_resource.wsgi_file
    port new_resource.port
  end
end
