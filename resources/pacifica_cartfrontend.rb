# Default properties which install and configures Pacifica cart frontend using wsgi
resource_name :pacifica_cartfrontend

property :name, name_property: true
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
    environment: {
      VOLUME_PATH: "#{prefix_dir}/cartdata/",
      LRU_BUFFER_TIME: 0,
      MYSQL_ENV_MYSQL_PASSWORD: 'cart',
      MYSQL_ENV_MYSQL_USER: 'cart'
    }
  }
}
property :wsgi_file, String, default: 'cartserver.py'
property :port, Integer, default: 8081

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
