require 'digest'
# pacifica cookbook module
module PacificaCookbook
  # Manages the Pacifica nginx service
  class PacificaNginx < ChefCompat::Resource
    property :name, String, name_property: true
    property :backend_hosts, Array, default: []
    property :listen_port, Integer, default: 9000
    property :nginx_opts, Hash, default: {}
    property :nginx_site_opts, Hash, default: {}

    resource_name :pacifica_nginx

    default_action :create

    action :create do
      include_recipe 'chef-sugar'
      include_recipe 'selinux_policy::install'
      package 'nginx'
      selinux_policy_port listen_port do
        protocol 'tcp'
        secontext 'http_port_t'
        only_if { rhel? }
      end
      selinux_policy_boolean 'httpd_can_network_connect' do
        value true
        only_if { rhel? }
      end
      template "nginx_#{name}_conf" do
        cookbook 'pacifica'
        source 'nginx.conf.erb'
        path '/etc/nginx/nginx.conf'
        nginx_opts.each do |key, attr|
          send(key, attr)
        end
      end
      template "nginx_#{name}_site_conf" do
        cookbook 'pacifica'
        source 'nginx-site.conf.erb'
        path "/etc/nginx/conf.d/#{name}.conf"
        variables(
          name: new_resource.name,
          server_name: 'localhost.localdomain',
          listen_port: new_resource.listen_port,
          backend_hosts: new_resource.backend_hosts
        )
        nginx_site_opts.each do |key, attr|
          send(key, attr)
        end
      end
      service 'nginx' do
        action [:enable, :start]
      end
    end
  end
end
