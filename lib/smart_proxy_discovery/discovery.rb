module Proxy::Discovery
  class NotFound < RuntimeError; end

  class Plugin < ::Proxy::Plugin
    plugin 'discovery', Proxy::Discovery::VERSION

    rackup_path File.expand_path('http_config.ru', __dir__)
    default_settings :node_scheme => 'https', :node_port => 8443
  end
end
