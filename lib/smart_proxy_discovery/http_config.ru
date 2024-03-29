# frozen_string_literal: true

require 'smart_proxy_discovery/discovery_api'

map '/discovery' do
  run Proxy::Discovery::Dispatcher.new
end
