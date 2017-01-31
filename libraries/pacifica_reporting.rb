# pacifica cookbook module
module PacificaCookbook
  require_relative 'pacifica_base_php'
  # installs and configures pacifica cart frontend wsgi
  class PacificaReporting < PacificaBasePhp
    property :name, String, name_property: true
    property :git_opts, Hash, default: {
      repository: 'https://github.com/EMSL-MSC/pacifica-reporting.git',
    }
    property :ci_prod_template_vars, Hash, default: {
      base_url: 'http://127.0.0.1',
      db_host: '127.0.0.1',
      db_user: 'reporting',
      db_pass: 'reporting',
      db_name: 'reporting',
      db_driver: 'postgres',
      cache_on: 'TRUE',
      cache_dir: '/tmp',
      timezone: 'UTC',
    }
    resource_name :pacifica_reporting
  end
end
