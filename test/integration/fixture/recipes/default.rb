docker_service 'default' do
  action [:create, :start]
end
pacifica_archiveinterface 'default'
pacifica_messaging 'default'
pacifica_loadbalancer 'default'
docker_image 'elasticsearch' do
  tag '2.4'
end
docker_image 'postgres' do
  tag '9.4'
end
docker_container 'pacifica_elasticsearch' do
  repo 'elasticsearch'
  tag '2.4'
end
docker_container 'pacifica_postgres' do
  repo 'postgres'
  tag '9.4'
  env %w(
    POSTGRES_PASSWORD=pacifica
    POSTGRES_DB=pacifica_metadata
    POSTGRES_USER=pacifica
  )
end
meta_properties = {
  links: %w(
    pacifica_postgres:postgres
    pacifica_elasticsearch:elasticsearch
  ),
  env: %w(
    ELASTICDB_PORT=tcp://elasticsearch:9200
    POSTGRES_ENV_POSTGRES_DB=pacifica_metadata
    POSTGRES_ENV_POSTGRES_USER=pacifica
    POSTGRES_PORT_5432_TCP_ADDR=postgres
    POSTGRES_ENV_POSTGRES_PASSWORD=pacifica
  )
}
execute 'sleep 10'
pacifica_metadata 'default' do
  container_properties meta_properties
end
policy_properties = {
  links: %w(pacifica_metadata_:metadata),
}
pacifica_policy 'default' do
  container_properties policy_properties
end
