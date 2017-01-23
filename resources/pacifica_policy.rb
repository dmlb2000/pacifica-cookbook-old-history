# Installs and configures the Pacifica policy service
resource_name :pacifica_policy

property :name, name_property: true
property :git_opts, Hash, default: {
  repository: 'https://github.com/EMSL-MSC/pacifica-policy.git'
}
property :wsgi_file, String, default: 'PolicyServer.py'
property :port, Integer, default: 8181

# action_class do
#   extend PacificaCookbook::PacificaHelpers::Directories
# end

default_action :create

action :create do
  extend PacificaCookbook::PacificaHelpers::Directories
  pacifica_base new_resource.name do
    git_opts new_resource.git_opts
    wsgi_file new_resource.wsgi_file
    port new_resource.port
  end
end
