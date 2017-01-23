# Default properties which manages the Pacifica archiveinterface service
resource_name :pacifica_archiveinterface

property :name, name_property: true
property :prefix, String, default: '/opt'
property :git_opts, Hash, default: {
  repository: 'https://github.com/EMSL-MSC/pacifica-archiveinterface.git'
}

property :wsgi_file, String, default: 'archiveinterface/wsgi.py'
property :port, Integer, default: 8080

property :file_script_opts, Hash, default: lazy {
  {
    content: <<-EOF
  #!/bin/bash
  . #{virtualenv_dir}/bin/activate
  export LD_LIBRARY_PATH=/opt/chef/embedded/lib
  export LD_RUN_PATH=/opt/chef/embedded/lib
  cd /
  exec -a #{name} #{run_command}
  EOF
  }
}

# action_class do
#   extend PacificaCookbook::PacificaHelpers::Directories
# end

default_action :create

action :create do
  extend PacificaCookbook::PacificaHelpers::Directories
  pacifica_base new_resource.name do
    git_opts new_resource.git_opts
    file_script_opts new_resource.file_script_opts
    wsgi_file new_resource.wsgi_file
    port new_resource.port
  end
end
