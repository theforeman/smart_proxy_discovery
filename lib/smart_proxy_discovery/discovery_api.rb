require 'sinatra'
require 'smart_proxy_discovery/discovery'
require 'smart_proxy_discovery/discovery_main'

module Proxy::Discovery

  class Api < ::Sinatra::Base
    helpers ::Proxy::Helpers
    authorize_with_trusted_hosts(/\/[^\/]+\/(facts|reboot)/)

    # DISCOVERED HOSTS -> PROXY -> FOREMAN actions (not authorized)
    post '/create' do
      content_type :json
      begin
        Proxy::Discovery.create_discovered_host(request)
      rescue => error
        error_responder(error)
      end
    end

    # FOREMAN -> PROXY -> DISCOVERED HOSTS actions (authorize_with_trusted_hosts)
    get '/:ip/facts' do
      content_type :json
      begin
        Proxy::Discovery.refresh_facts(params[:ip])
      rescue => error
        error_responder(error)
      end
    end

    put '/:ip/reboot' do
      content_type :json
      begin
        Proxy::Discovery.reboot(params[:ip])
      rescue => error
        error_responder(error)
      end
    end

    private

    def error_responder(error)
      error_code = error.respond_to?(:http_code) ? error.http_code : 500
      log_halt(error_code, "failed to update Foreman: #{error}")
    end
  end
end
