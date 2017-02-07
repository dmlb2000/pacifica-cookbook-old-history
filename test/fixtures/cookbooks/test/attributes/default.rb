default['postgresql']['password']['postgres'] = 'postgres'
default['java']['jdk_version'] = '8'
case node['platform_family']
when 'rhel'
  override['elasticsearch']['install']['version'] = '5.1.2'
when 'debian'
  default['elasticsearch']['install']['version'] = '5.2.0'
end
