if defined?(ChefSpec)
  def install_kubectl(message)
    ChefSpec::Matchers::ResourceMatcher.new(:kubectl, :install, message)
  end
end
