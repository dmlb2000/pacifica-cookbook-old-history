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
    property :db_create_opts, Hash, default: lazy {
      {
        cwd: source_dir,
        command: "sh #{source_dir}/db_setup.sh && touch #{prefix_dir}/.dbcreate",
        not_if: "test -e #{prefix_dir}/.dbcreate",
        only_if: "test -e #{source_dir}/db_setup.sh",
      }
    }
    property :ci_prod_template_opts, Hash, default: {}
    property :ci_prod_template_vars, Hash, default: {
      base_url: 'http://127.0.0.1',
      db_host: '',
      db_user: '',
      db_pass: '',
      db_name: 'database.db',
      db_driver: 'sqlite',
      cache_on: 'TRUE',
      cache_dir: '/tmp',
      timezone: 'UTC',
    }

    def prefix_dir
      "#{prefix}/#{name}"
    end

    def source_dir
      "#{prefix_dir}/source"
    end

    default_action :create

    action :create do
      require 'ipaddress'
      include_recipe 'chef-sugar'
      include_recipe 'selinux_policy::install' if rhel?
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
      directory "#{source_dir}/application/logs"
      apache_user = if rhel?
                      package 'httpd'
                      'apache'
                    else
                      package 'apache2'
                      'www-data'
                    end
      execute "chown -R #{apache_user}:#{apache_user} #{source_dir}"
      template 'create_prod_config' do
        source 'ci-prod-config.php.erb'
        path "#{source_dir}/application/config/production/config.php"
        ci_prod_template_opts.each do |attr, value|
          send(attr, value)
        end
        cookbook 'pacifica'
        variables(ci_prod_template_vars)
      end
      execute "chcon -R system_u:object_r:httpd_sys_content_t:s0 #{source_dir}" do
        only_if { rhel? }
      end
      include_recipe 'php'
      include_recipe 'php::module_pgsql'
      include_recipe 'php::module_sqlite3'
      include_recipe 'php::module_gd'
      # do some calculations to make it work based on system size
      default_attrs = {
        max_children: node['cpu']['total'] * 4,
        start_servers: node['cpu']['total'],
        min_spare_servers: node['cpu']['total'],
        max_spare_servers: node['cpu']['total'],
      }
      ipaddress, listen_port = if php_fpm_opts.key?(:listen)
                                 php_fpm_opts[:listen].split(':')
                               else
                                 %w(127.0.0.1 9000)
                               end
      selinux_policy_port listen_port do
        protocol 'tcp'
        secontext 'http_port_t'
        only_if { rhel? && IPAddress.valid?(ipaddress) }
      end
      selinux_policy_boolean 'httpd_can_network_connect' do
        value true
        only_if { rhel? }
      end
      execute "#{name}-db-create" do
        environment CI_ENV: 'production'
        db_create_opts.each do |attr, value|
          send(attr, value)
        end
      end
      php_fpm_pool name do
        listen "/var/run/php5-fpm-#{name}.sock"
        chdir source_dir
        max_children
        notifies :restart, "service[#{node['php']['fpm_service']}]"
        default_attrs.merge(php_fpm_opts).each do |attr, value|
          send(attr, value)
        end
      end
      service node['php']['fpm_service'] do
        action [:enable, :start]
      end
    end
  end
end
