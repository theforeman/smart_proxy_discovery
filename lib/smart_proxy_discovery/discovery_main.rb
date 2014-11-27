require 'rest-client'
require 'proxy/request'

module Proxy::Discovery
  extend ::Proxy::Util
  extend ::Proxy::Log

  class << self
    CREATE_DISCOVERED_HOST_PATH = '/api/v2/discovered_hosts/facts'
    REFRESH_HOST_PATH           = '/facts'

    def create_discovered_host(params)
      foreman_request = Proxy::HttpRequest::ForemanRequest.new()
      foreman_request.send_request(foreman_request.request_factory.create_post(CREATE_DISCOVERED_HOST_PATH, params.to_json))
    end

    def refresh_facts(ip)
      url    = "http://#{ip}:8443"
      client = get_rest_client(url)
      client[REFRESH_HOST_PATH].get
    end

    def reboot(ip)
      url         = "http://#{ip}:8443"
      reboot_path = "/bmc/#{ip}/chassis/power/cycle"
      client      = get_rest_client(url)
      client[reboot_path].put({})
    end

    private

    def get_rest_client(url)
      RestClient::Resource.new(
          url,
          :verify_ssl => OpenSSL::SSL::VERIFY_NONE
      )
    end
  end
end
