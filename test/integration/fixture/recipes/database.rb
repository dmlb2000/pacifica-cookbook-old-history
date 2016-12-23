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
  password: 'postgres'
}
mysql_connection_info = {
  host: '127.0.0.1',
  socket: '/var/run/mysql-default/mysqld.sock',
  username: 'root',
  password: 'mysql'
}

{
  cartd: {
    cart: 'cart'
  }
}.each do |dbname, users|
  mysql_database "#{dbname}" do
    connection mysql_connection_info
  end
  users.each do |username, password|
    mysql_database_user username do
      connection mysql_connection_info
      password password
      database_name "#{dbname}"
      action :grant
    end
  end
end
