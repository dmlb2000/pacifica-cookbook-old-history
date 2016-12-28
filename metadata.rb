name 'pacifica'
maintainer 'David Brown'
maintainer_email 'dmlb2000@gmail.com'
license 'all_rights'
description 'Installs/Configures pacifica'
long_description 'Installs/Configures pacifica'
version '0.1.0'
if respond_to?(:issues_url)
  issues_url 'https://github.com/pacifica/pacifica-cookbook/issues'
end
if respond_to?(:source_url)
  source_url 'https://github.com/pacifica/pacifica-cookbook'
end

depends 'git'
depends 'poise-python'
depends 'systemd'
depends 'php'
