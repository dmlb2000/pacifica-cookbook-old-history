include_recipe 'fake::database'
include_recipe 'fake::messaging'
include_recipe 'fake::elasticsearch'
pacifica_archiveinterface 'archiveinterface'
pacifica_cartfrontend 'cartwsgi'
pacifica_cartbackend 'cartd'
pacifica_metadata 'metadata'
