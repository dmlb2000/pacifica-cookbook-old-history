# Installs and configures the Pacifica metadata service
resource_name :pacifica_metadata

property :git_opts, Hash, default: {
  repository: 'https://github.com/EMSL-MSC/pacifica-metadata.git'
}
property :service_opts, Hash, default: {
  environment: {
    POSTGRES_ENV_POSTGRES_DB: 'metadata',
    POSTGRES_ENV_POSTGRES_USER: 'metadata',
    POSTGRES_ENV_POSTGRES_PASSWORD: 'metadata'
  }
}
property :wsgi_file, String, default: 'MetadataServer.py'
property :port, Integer, default: 8121

default_action :create

action :create do
  extend PacificaCookbook::PacificaHelpers::Directories
  pacifica_base new_resource.name do
    git_opts new_resource.git_opts
    service_opts new_resource.service_opts
    wsgi_file new_resource.wsgi_file
    port new_resource.port
  end
end
