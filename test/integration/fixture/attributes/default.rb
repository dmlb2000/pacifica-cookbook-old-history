default['postgresql']['password']['postgres'] = 'postgres'
default['java']['jdk_version'] = '8'
default['elasticsearch']['install']['version'] = '5.1.1'
default['nginx']['conf_cookbook'] = 'fake'
default['ohai']['plugin_path'] = ::File.join('etc', 'chef', 'ohai', 'plugins')
