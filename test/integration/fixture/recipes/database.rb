include_recipe 'database::postgresql'
include_recipe 'postgresql::server'

include_recipe 'yum-mysql-community::mysql56'
mysql2_chef_gem 'default' do
  provider Chef::Provider::Mysql2ChefGem::Mysql
end
mysql_service 'default' do
  initial_root_password 'mysql'
  action [:create, :start]
end

postgresql_connection_info = {
  host: '127.0.0.1',
  port: node['postgresql']['config']['port'],
  username: 'postgres',
  password: 'postgres',
}
mysql_connection_info = {
  host: '127.0.0.1',
  socket: '/var/run/mysql-default/mysqld.sock',
  username: 'root',
  password: 'mysql',
}

{
  cartd: {
    users: {
      cart: 'cart',
    },
    db_provider: Chef::Provider::Database::Mysql,
    user_provider: Chef::Provider::Database::MysqlUser,
    user_actions: [:grant],
    connection_info: mysql_connection_info,
  },
  metadata: {
    users: {
      metadata: 'metadata',
    },
    db_provider: Chef::Provider::Database::Postgresql,
    user_provider: Chef::Provider::Database::PostgresqlUser,
    user_actions: [:create, :grant],
    connection_info: postgresql_connection_info,
  },
}.each do |dbname, data|
  database dbname.to_s do
    provider data[:db_provider]
    connection data[:connection_info]
  end
  data[:users].each do |username, password|
    database_user username do
      provider data[:user_provider]
      connection data[:connection_info]
      password password
      database_name dbname.to_s
      action data[:user_actions]
    end
  end
end
