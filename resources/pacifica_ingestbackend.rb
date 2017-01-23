# require_relative 'pacifica_base'
# installs and configures pacifica ingest backend celery
resource_name :pacifica_ingestbackend

property :git_opts, Hash, default: {
  repository: 'https://github.com/EMSL-MSC/pacifica-ingest.git'
}
property :service_opts, Hash, default: lazy {
  {
    environment: {
      PYTHONPATH: "#{virtualenv_dir}/lib/python2.7/site-packages",
      VOLUME_PATH: "#{prefix_dir}/ingestdata",
      MYSQL_ENV_MYSQL_PASSWORD: 'ingest',
      MYSQL_ENV_MYSQL_USER: 'ingest'
    }
  }
}
property :run_command, String, default: lazy {
  "#{virtualenv_dir}/bin/python -m celery -A ingest.backend worker -l info"
}

# action_class do
#   extend PacificaCookbook::PacificaHelpers::Directories
# end

default_action :create

action :create do
  extend PacificaCookbook::PacificaHelpers::Directories
  pacifica_base new_resource.name do
    git_opts new_resource.git_opts
    service_opts new_resource.service_opts
    run_command new_resource.run_command
  end
end
