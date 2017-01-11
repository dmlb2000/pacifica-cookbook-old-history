default['postgresql']['password']['postgres'] = 'postgres'
default['java']['jdk_version'] = '8'
default['elasticsearch']['install']['version'] = '5.1.1'
default['ohai']['plugin_path'] = ::File.join(::File.dirname(Chef::Config['config_file']), 'ohai', 'plugins')
