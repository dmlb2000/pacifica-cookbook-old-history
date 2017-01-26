# pacifica cookbook module
module PacificaCookbook
  require_relative 'helpers_base_dir'
  # Pacifica base class with common properties and actions
  class PacificaBasePhp < ChefCompat::Resource
    property :prefix, String, default: '/opt'
    property :site_fqdn, String, default: 'http://127.0.0.1'
    property :directory_opts, Hash, default: {}
    property :git_opts, Hash, default: {}
    property :git_client_opts, Hash, default: {}
    property :php_fpm_opts, Hash, default: {}

    default_action :create

    action :create do
      extend PacificaHelpers::BaseDirectories
      require 'ipaddress'

      include_recipe 'chef-sugar'
      include_recipe 'selinux_policy::install' if rhel?

      # Install the git_client
      git_client "#{name}_client" do
        git_client_opts.each do |attr, value|
          send(attr, value)
        end
      end

      directory prefix_dir do
        directory_opts.each do |attr, value|
          send(attr, value)
        end
      end

      # Clone the provided repository and include submodules
      git source_dir do
        enable_submodules true
        git_opts.each do |attr, value|
          send(attr, value)
        end
      end

      directory "#{source_dir}/application/logs"

      include_recipe 'apache2'
      apache_user = if rhel?
                      'apache'
                    else
                      'www-data'
                    end

      # ALL the files under #{source_dir} need to be owned by #{apache_user}
      execute "chown_#{name}_files" do
        command "chown -R #{apache_user}:#{apache_user} #{source_dir}"
      end

      # Doing this because a PHP template is ugly
      execute "create_#{name}_fqdn" do
        command %(echo "\\$config['base_url'] = '#{site_fqdn}';" >> #{source_dir}/application/config/production/config.php)
        not_if "grep -q #{site_fqdn} #{source_dir}/application/config/production/config.php"
      end

      # Prep the git clone selinux context
      execute "set_#{name}_selinux_context" do
        command "chcon -R system_u:object_r:httpd_sys_content_t:s0 #{source_dir}"
        only_if { rhel? }
      end

      # Install and prep PHP and modules
      include_recipe 'php'
      include_recipe 'php::module_pgsql'
      include_recipe 'php::module_sqlite3'
      include_recipe 'php::module_gd'

      default_attrs = {
        max_children: node['cpu']['total'] * 4,
        start_servers: node['cpu']['total'],
        min_spare_servers: node['cpu']['total'],
        max_spare_servers: node['cpu']['total']
      }

      ipaddress, listen_port = if php_fpm_opts.key?(:listen)
                                 php_fpm_opts[:listen].split(':')
                               else
                                 %w(127.0.0.1 9000)
                               end
      # Set SELinux Policy Port
      selinux_policy_port "#{name}_#{listen_port}" do
        port listen_port
        protocol 'tcp'
        secontext 'http_port_t'
        only_if { rhel? && IPAddress.valid?(ipaddress) }
      end

      # Set SELinux Policy Boolean
      selinux_policy_boolean "#{name}_httpd" do
        name 'httpd_can_network_connect'
        value true
        only_if { rhel? }
      end

      php_fpm_pool "#{node['php']['fpm_service']}_#{name}" do
        pool_name name
        listen "/var/run/php5-fpm-#{name}.sock"
        chdir source_dir
        max_children
        notifies :restart, "service[#{name}]"
        default_attrs.merge(php_fpm_opts).each do |attr, value|
          send(attr, value)
        end
      end

      service "#{node['php']['fpm_service']}_#{name}" do
        service_name node['php']['fpm_service']
        action [:enable, :start]
      end
    end
  end
end
