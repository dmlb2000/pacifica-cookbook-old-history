# Installs and configures the Pacifica uniqueid service
resource_name :pacifica_uniqueid

property :name, name_property: true
property :git_opts, Hash, default: {
  repository: 'https://github.com/EMSL-MSC/pacifica-uniqueid.git'
}
property :service_opts, Hash, default: {
  environment: {
    MYSQL_PORT_3306_TCP_ADDR: '127.0.0.1',
    MYSQL_ENV_MYSQL_DATABASE: 'uniqueid',
    MYSQL_ENV_MYSQL_USER: 'uniqueid',
    MYSQL_ENV_MYSQL_PASSWORD: 'uniqueid'
  }
}
property :wsgi_file, String, default: 'UniqueIDServer.py'
property :port, Integer, default: 8051

# action_class do
#   extend PacificaCookbook::PacificaHelpers::Directories
# end

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
