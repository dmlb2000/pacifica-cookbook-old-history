# pacifica cookbook module
module PacificaCookbook
  require_relative 'pacifica_base_php'
  # installs and configures pacifica cart frontend wsgi
  class PacificaStatus < PacificaBasePhp
    property :name, String, name_property: true
    property :git_opts, Hash, default: {
      repository: 'https://github.com/EMSL-MSC/pacifica-upload-status.git',
    }
    property :ci_prod_template_vars, Hash, default: {
      base_url: 'http://127.0.0.1',
      db_host: '127.0.0.1',
      db_user: 'status',
      db_pass: 'status',
      db_name: 'status',
      db_driver: 'postgres',
      cache_on: 'TRUE',
      cache_dir: '/tmp',
      timezone: 'UTC',
    }
    resource_name :pacifica_status
  end
end
