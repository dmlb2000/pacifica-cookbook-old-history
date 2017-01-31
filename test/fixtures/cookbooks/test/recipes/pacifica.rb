pacifica_archiveinterface 'archiveinterface'
pacifica_cartfrontend 'cartwsgi'
pacifica_cartbackend 'cartd'
pacifica_metadata 'metadata'
pacifica_policy 'policy'
pacifica_uniqueid 'uniqueid'
pacifica_ingestbackend 'ingestd'
pacifica_ingestfrontend 'ingestwsgi'
pacifica_uploaderbackend 'uploaderd'
pacifica_uploaderfrontend 'uploaderwsgi'
pacifica_status 'status'
pacifica_reporting 'reporting'
pacifica_nginx 'nginxai' do
  backend_hosts ['127.0.0.1:8080']
end
pacifica_varnish 'varnishai' do
  backend_hosts ['127.0.0.1:8080']
end
