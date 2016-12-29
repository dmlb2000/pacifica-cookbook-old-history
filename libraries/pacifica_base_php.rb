# pacifica cookbook module
module PacificaCookbook
  # Pacifica base class with common properties and actions
  class PacificaBasePhp < ChefCompat::Resource
    ################
    # Properties
    ################
    property :prefix, String, default: '/opt'
    property :directory_opts, Hash, default: {}
    property :git_opts, Hash, default: {}
    property :git_client_opts, Hash, default: {}
    property :php_fpm_opts, Hash, default: {}

    def prefix_dir
      "#{prefix}/#{name}"
    end

    def source_dir
      "#{prefix_dir}/source"
    end

    default_action :create

    action :create do
      git_client name do
        git_client_opts.each do |attr, value|
          send(attr, value)
        end
      end
      directory prefix_dir do
        directory_opts.each do |attr, value|
          send(attr, value)
        end
      end
      git source_dir do
        enable_submodules true
        git_opts.each do |attr, value|
          send(attr, value)
        end
      end
      include_recipe 'php'
      include_recipe 'php::module_pgsql'
      include_recipe 'php::module_sqlite3'
      include_recipe 'php::module_gd'
      php_fpm_pool name do
        listen "/var/run/php5-fpm-#{name}.sock"
        chdir source_dir
        php_fpm_opts.each do |attr, value|
          send(attr, value)
        end
      end
    end
  end
end
