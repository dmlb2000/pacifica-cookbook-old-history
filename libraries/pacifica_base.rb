module PacificaCookbook
  # Pacifica base class with common properties and actions
  class PacificaBase < ChefCompat::Resource
    ################
    # Properties
    ################
    property :prefix, String, default: '/opt'
    property :directory_opts, Hash, default: {}
    property :virtualenv_opts, Hash, default: {}
    property :python_opts, Hash, default: { version: '2.7' }
    property :pip_install_opts, Hash, default: {}
    property :build_opts, Hash, default: {}
    property :git_opts, Hash, default: {}
    property :git_client_opts, Hash, default: {}
    property :service_opts, Hash, default: {}

    ##################
    # Helper Methods
    ##################
    def prefix_dir
      "#{prefix}/#{name}"
    end

    def virtualenv_dir
      "#{prefix_dir}/virtualenv"
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
        git_opts.each do |attr, value|
          send(attr, value)
        end
      end
      python_runtime name do
        python_opts.each do |attr, value|
          send(attr, value)
        end
      end
      python_virtualenv virtualenv_dir do
        virtualenv_opts.each do |attr, value|
          send(attr, value)
        end
      end
      python_execute "#{name}_requirements" do
        virtualenv virtualenv_dir
        command "-m pip install -r #{source_dir}/requirements.txt"
        pip_install_opts.each do |attr, value|
          send(attr, value)
        end
      end
      python_execute "#{name}_build" do
        virtualenv virtualenv_dir
        cwd source_dir
        command "setup.py install --prefix #{virtualenv_dir}"
        only_if { ::File.exist?("#{source_dir}/setup.py") }
        build_opts.each do |attr, value|
          send(attr, value)
        end
      end
      service_env = {
        VIRTUAL_ENV: virtualenv_dir,
        PATH: %W(
          #{virtualenv_dir}/bin
          /usr/local/sbin
          /usr/local/bin
          /sbin
          /bin
          /usr/sbin
          /usr/bin
        ).join(':')
      }
      if service_opts.key?(:environment)
        service_env = service_env.merge(service_opts.delete(:environment))
      end
      systemd_service name do
        description "start #{name} in python"
        after %w( network.target )
        install do
          wanted_by 'multi-user.target'
        end
        service do
          working_directory source_dir
          environment service_env
          exec_start "#{virtualenv_dir}/bin/python #{source_dir}/server.py"
          service_opts.each do |attr, value|
            send(attr, value)
          end
        end
      end
      service name do
        action [:enable, :start]
      end
    end
  end
end
