if defined?(ChefSpec)
  def create_pacifica_archiveinterface(name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :pacifica_archiveinterface, :create, name
    )
  end
end
