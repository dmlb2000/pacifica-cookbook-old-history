if defined?(ChefSpec)
  def create_pacifica_archiveinterface(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_archiveinterface, :create, resource_name
    )
  end

  def create_pacifica_cartbackend(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_cartbackend, :create, resource_name
    )
  end

  def create_pacifica_cartfrontend(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_cartfrontend, :create, resource_name
    )
  end

  def create_pacifica_ingestbackend(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_archiveinterface, :create, resource_name
    )
  end

  def create_pacifica_ingestfrontend(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_ingestfrontend, :create, resource_name
    )
  end

  def create_pacifica_metadata(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_metadata, :create, resource_name
    )
  end

  def create_pacifica_nginx(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_nginx, :create, resource_name
    )
  end

  def create_pacifica_policy(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_policy, :create, resource_name
    )
  end

  def create_pacifica_reporting(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_reporting, :create, resource_name
    )
  end

  def create_pacifica_status(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_status, :create, resource_name
    )
  end

  def create_pacifica_uniqueid(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_uniqueid, :create, resource_name
    )
  end

  def create_pacifica_varnish(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_varnish, :create, resource_name
    )
  end
end
