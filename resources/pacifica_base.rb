# Primary resource for core Pacifica services
resource_name :pacifica_base

property :name, name_property: true
property :prefix, String, default: '/opt'
property :directory_opts, Hash, default: {}
property :git_client_opts, Hash
property :git_config_opts, Hash
property :git_opts, Hash
property :python_runtime_opts, Hash, default: { version: '2.7' }
property :python_virtualenv_opts, Hash, default: {}
property :requirements_command, String, default: lazy {
  "-m pip install -r #{source_dir}/requirements.txt"
}
property :requirements_install_opts, Hash, default: {}
property :uwsgi_command, String, default: '-m pip install uwsgi'
property :uwsgi_opts, String, default: '-m pip install uwsgi'
property :build_command, String, default: lazy {
  "setup.py install --prefix #{virtualenv_dir}"
}
property :build_opts, Hash, default: {}
property :file_script_opts, Hash, default: lazy {
  {
    content: <<-EOF
    #!/bin/bash
    . #{virtualenv_dir}/bin/activate
    export PYTHONPATH=#{virtualenv_dir}/lib64/python2.7/site-packages
    export LD_LIBRARY_PATH=/opt/chef/embedded/lib
    export LD_RUN_PATH=/opt/chef/embedded/lib
    cd #{source_dir}
    exec -a #{name} #{run_command}
    EOF
  }
}
property :service_opts, Hash, default: {}
property :wsgi_file, String, default: 'server.py'
property :port, Integer, default: 8080
property :run_command, String, default: lazy {
  "#{virtualenv_dir}/bin/uwsgi "\
  "--http-socket :#{port} "\
  "--master -p #{node['cpu']['total']} "\
  "--wsgi-file #{source_dir}/#{wsgi_file}"
}

# action_class do
#   extend PacificaCookbook::PacificaHelpers::Directories
# end

default_action :create

action :create do
  extend PacificaCookbook::PacificaHelpers::Directories
  puts prefix_dir
  puts virtualenv_dir
  puts source_dir

  directory prefix_dir do
    directory_opts.each do |attr, value|
      send(attr, value)
    end
  end

  git_client name do
    git_client_opts.each do |attr, value|
      send(attr, value)
    end
    action :install
  end

  git_config name do
    git_config_opts.each do |attr, value|
      send(attr, value)
    end
    not_if git_config_opts.nil?
  end

  git source_dir do
    git_opts.each do |attr, value|
      send(attr, value)
    end
    notifies :restart, "service[#{name}]"
    not_if git_opts.nil?
  end

  python_runtime name do
    python_runtime_opts.each do |attr, value|
      send(attr, value)
    end
  end

  python_virtualenv virtualenv_dir do
    python_virtualenv_opts.each do |attr, value|
      send(attr, value)
    end
  end

  python_execute "#{name}_requirements" do
    virtualenv virtualenv_dir
    command py_requirements_command
    requirements_install_opts.each do |attr, value|
      send(attr, value)
    end
  end

  python_execute "#{name}_uwsgi" do
    virtualenv virtualenv_dir
    command py_uwsgi_command
    not_if { File.exist?("#{virtualenv_dir}/bin/uwsgi") }
  end

  python_execute "#{name}_build" do
    virtualenv virtualenv_dir
    cwd source_dir
    command py_build_command
    only_if { File.exist?("#{source_dir}/setup.py") }
    build_opts.each do |attr, value|
      send(attr, value)
    end
  end

  file "#{prefix_dir}/#{name}" do
    owner 'root'
    group 'root'
    mode '0700'
    file_script_opts.each do |attr, value|
      send(attr, value)
    end
    notifies :restart, "service[#{name}]"
  end

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

  service name do
    action [:enable, :start]
  end
end
