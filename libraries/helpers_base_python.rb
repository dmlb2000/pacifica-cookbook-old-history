# Pacifica Cookbook Modules
module PacificaCookbook
  # Pacifica Cookbook Helpers
  module PacificaHelpers
    # Directories which should get defined via properties
    module BasePython
      # Define python resources
      def base_python_runtime
        python_runtime name do
          python_opts.each do |attr, value|
            send(attr, value)
          end
        end
      end

      def base_python_virtualenv
        python_virtualenv virtualenv_dir do
          virtualenv_opts.each do |attr, value|
            send(attr, value)
          end
        end
      end

      def base_python_execute_requirements
        python_execute "#{name}_requirements" do
          virtualenv virtualenv_dir
          command "-m pip install -r #{source_dir}/requirements.txt"
          pip_install_opts.each do |attr, value|
            send(attr, value)
          end
        end
      end

      def base_python_execute_uwsgi
        python_execute "#{name}_uwsgi" do
          virtualenv virtualenv_dir
          command '-m pip install uwsgi'
          not_if { ::File.exist?("#{virtualenv_dir}/bin/uwsgi") }
        end
      end

      def base_python_execute_build
        python_execute "#{name}_build" do
          virtualenv virtualenv_dir
          cwd source_dir
          command "setup.py install --prefix #{virtualenv_dir}"
          only_if { ::File.exist?("#{source_dir}/setup.py") }
          build_opts.each do |attr, value|
            send(attr, value)
          end
        end
      end
    end
  end
end
