module Proxy::Discovery
  class NotFound < RuntimeError; end

  class Plugin < ::Proxy::Plugin
    plugin 'discovery', Proxy::Discovery::VERSION

    http_rackup_path File.expand_path('http_config.ru', File.expand_path('../', __FILE__))
    https_rackup_path File.expand_path('http_config.ru', File.expand_path('../', __FILE__))
    default_settings :node_scheme => 'https', :node_port => 8443
  end
end
