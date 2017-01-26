# Pacifica Cookbook Modules
module PacificaCookbook
  # Pacifica Cookbook Helpers
  module PacificaHelpers
    # Helpers to call within the base action
    module Base
      # Create prefixed directories
      def base_directory_resources
        directory prefix_dir do
          directory_opts.each do |attr, value|
            send(attr, value)
          end
        end
      end

      def base_git_client
        git_client name do
          git_client_opts.each do |attr, value|
            send(attr, value)
          end
        end
      end

      def base_git
        git source_dir do
          notifies :restart, "service[#{new_resource.name}]"
          git_opts.each do |attr, value|
            send(attr, value)
          end
        end
      end

      def base_file
        file "#{prefix_dir}/#{name}" do
          owner 'root'
          group 'root'
          mode '0700'
          content <<-HDOC
#!/bin/bash
. #{virtualenv_dir}/bin/activate
export PYTHONPATH=#{virtualenv_dir}/lib64/python2.7/site-packages
export LD_LIBRARY_PATH=/opt/chef/embedded/lib
export LD_RUN_PATH=/opt/chef/embedded/lib
cd #{source_dir}
exec -a #{new_resource.name} #{run_command}
HDOC
          notifies :restart, "service[#{new_resource.name}]"
          script_opts.each do |attr, value|
            send(attr, value)
          end
        end
      end

      def base_systemd_service
        systemd_service name do
          description "start #{name} in python"
          after %w(network.target)
          install do
            wanted_by 'multi-user.target'
          end
          service do
            working_directory source_dir
            exec_start "#{prefix_dir}/#{name}"
            service_opts.each do |attr, value|
              send(attr, value)
            end
          end
          notifies :restart, "service[#{new_resource.name}]"
        end
      end

      def base_service
        service name do
          action [:enable, :start]
        end
      end
    end
  end
end
