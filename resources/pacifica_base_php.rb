# Primary resource for Pacifica reporting and status services
resource_name :pacifica_base_php

property :name, name_property: true
property :prefix, String, default: '/opt'
property :directory_opts, Hash, default: {}
property :site_fqdn, String, default: 'http://127.0.0.1'
property :git_client_opts, Hash, default: {}
property :git_config_opts, Hash, default: {}
property :git_opts, Hash, default: {}
property :php_fpm_opts, Hash, default: {}
property :selinux_context_command, String, default: lazy {
  "chcon -R system_u:object_r:httpd_sys_content_t:s0 #{source_dir}"
}

action_class do
  require 'ipaddress'
  # extend PacificaCookbook::PacificaHelpers::Directories
end

default_action :create

action :create do
  extend PacificaCookbook::PacificaHelpers::Directories
  # prefix_dir = "#{prefix}/#{name}"
  # source_dir = "#{prefix_dir}/source"
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

  apache_user = if platform_family?('rhel')
                  'apache'
                else
                  'www-data'
                end

  include_recipe 'chef-sugar'
  include_recipe 'selinux_policy::install' if platform_family?('rhel')

  directory prefix_dir do
    directory_opts.each do |attr, value|
      send(attr, value)
    end
  end

  # directory source_dir do
  #   owner apache_user
  #   group apache_user
  #   recursive true
  #   action :create
  # end

  # Test if working as expected
  directory "#{source_dir}/application/logs" do
    owner apache_user
    group apache_user
    recursive true
    action :create
  end

  # Install the git_client
  git_client name do
    git_client_opts.each do |attr, value|
      send(attr, value)
    end
    action :install
  end

  # Set a git config if desired
  git_config name do
    git_config_opts.each do |attr, value|
      send(attr, value)
    end
    not_if git_config_opts.nil?
  end

  # Clone the provided repository and include submodules
  git source_dir do
    enable_submodules true
    git_opts.each do |attr, value|
      send(attr, value)
    end
    notifies :run, "execute[chown_#{source_dir}]"
    notifies :restart, "service[#{name}]", :delayed
    not_if git_opts.nil?
  end

  # Doing this because a PHP template is ugly
  execute "create_#{name}_fqdn" do
    command %(echo "\\$config['base_url'] = '#{site_fqdn}';" >> #{source_dir}/application/config/production/config.php)
    not_if "grep -q #{site_fqdn} #{source_dir}/application/config/production/config.php"
    action :run
  end

  # ALL the files under #{source_dir} need to be owned by #{apache_user}
  execute "chown_#{source_dir}" do
    command "chown -R #{apache_user}:#{apache_user} #{source_dir}"
    user 'root'
    notifies :run, "execute[set_#{source_dir}_selinux_context]"
    action :nothing
  end

  # Prep the git clone selinux context
  execute "set_#{source_dir}_selinux_context" do
    command selinux_context_command
    only_if { platform_family?('rhel') }
    action :nothing
  end

  # Install and prep PHP and modules
  include_recipe 'php'
  include_recipe 'php::module_pgsql'
  include_recipe 'php::module_sqlite3'
  include_recipe 'php::module_gd'

  # Set SELinux Policy Port
  selinux_policy_port listen_port do
    protocol 'tcp'
    secontext 'http_port_t'
    only_if { platform_family?('rhel') && IPAddress.valid?(ipaddress) }
  end

  # Set SELinux Policy Boolean
  selinux_policy_boolean 'httpd_can_network_connect' do
    value true
    only_if { platform_family?('rhel') }
  end

  php_fpm_pool name do
    listen "/var/run/php5-fpm-#{name}.sock"
    chdir source_dir
    max_children
    notifies :restart, 'service[php-fpm]'
    default_attrs.merge(php_fpm_opts).each do |attr, value|
      send(attr, value)
    end
  end

  service 'php-fpm' do
    action [:enable, :start]
  end
end
