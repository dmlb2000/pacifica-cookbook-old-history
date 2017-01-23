# Installs and configures the Pacifica cart frontend wsgi
resource_name :pacifica_reporting

property :git_opts, Hash, default: {
  repository: 'https://github.com/EMSL-MSC/pacifica-reporting.git'
}

# action_class do
#   extend PacificaCookbook::PacificaHelpers::Directories
# end

default_action :create

action :create do
  extend PacificaCookbook::PacificaHelpers::Directories
  pacifica_base_php new_resource.name do
    git_opts new_resource.git_opts
  end
end
