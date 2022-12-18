require 'sinatra'
require 'smart_proxy_discovery/discovery'
require 'smart_proxy_discovery/discovery_main'

module Proxy::Discovery

  # This plugin has two separate Sinatra applications with different contexts
  # (authorization helpers). Inbound communication is unauthorized,
  class Dispatcher
    def call(env)
      if env['PATH_INFO'] == '/create'
        InboundApi.new.call(env)
      else
        OutboundApi.new.call(env)
      end
    end
  end

  module ApiHelpers
    def error_responder(error)
      error_code = error.respond_to?(:http_code) ? error.http_code : 500
      if error.respond_to?(:http_code) && error.respond_to?(:http_body)
        log_halt(error_code, "Proxy error HTTP #{error.http_code} (#{error.message}): #{error.http_body})")
      else
        log_halt(error_code, error)
      end
    end
  end

  # Inbound communication: Discovered Host -> Proxy Plugin -> Foreman
  class InboundApi < ::Sinatra::Base
    helpers ::Proxy::Helpers
    include ApiHelpers

    post '/create' do
      content_type :json
      begin
        Proxy::Discovery.create_discovered_host(request)
      rescue => error
        error_responder(error)
      end
    end
  end

  # Outbound communication: Foreman -> Proxy Plugin -> Discovered Host
  class OutboundApi < ::Sinatra::Base
    helpers ::Proxy::Helpers
    include ApiHelpers
    authorize_with_trusted_hosts

    get '/:ip/inventory/facter' do
      content_type :json
      begin
        Proxy::Discovery.inventory_facter(params[:ip])
      rescue => error
        error_responder(error)
      end
    end

    get '/:ip/facts' do
      content_type :json
      begin
        Proxy::Discovery.refresh_facts_legacy(params[:ip])
      rescue => error
        error_responder(error)
      end
    end

    put '/:ip/power/reboot' do
      content_type :json
      begin
        Proxy::Discovery.reboot(params[:ip])
      rescue => error
        error_responder(error)
      end
    end

    put '/:ip/power/kexec' do
      content_type :json
      begin
        Proxy::Discovery.kexec(params[:ip], request.body.read)
      rescue => error
        error_responder(error)
      end
    end

    put '/:ip/reboot' do
      content_type :json
      begin
        Proxy::Discovery.reboot_legacy(params[:ip])
      rescue => error
        error_responder(error)
      end
    end
  end
end
