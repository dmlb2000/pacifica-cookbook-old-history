default['postgresql']['password']['postgres'] = 'postgres'
default['java']['jdk_version'] = '8'
case node['platform_family']
when 'rhel'
  override['elasticsearch']['install']['version'] = '5.1.2'
when 'debian'
  default['elasticsearch']['install']['version'] = '5.2.0'
end

default['rabbitmq']['loopback_users'] = []
default['rabbitmq']['virtualhosts'] = %w(/cart /ingest /Uploader)
default['rabbitmq']['enabled_users'] = [
  {
    name: 'guest',
    password: 'guest',
    rights: [
      {
        vhost: '/Uploader',
        conf: '.*',
        write: '.*',
        read: '.*',
      },
      {
        vhost: '/cart',
        conf: '.*',
        write: '.*',
        read: '.*',
      },
      {
        vhost: '/ingest',
        conf: '.*',
        write: '.*',
        read: '.*',
      },
    ],
  },
]
