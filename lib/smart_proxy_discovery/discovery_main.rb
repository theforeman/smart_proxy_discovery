require 'rest-client'
require 'proxy/request'
require 'json'

module Proxy::Discovery
  extend ::Proxy::Util
  extend ::Proxy::Log

  class << self
    CREATE_DISCOVERED_HOST_PATH = '/api/v2/discovered_hosts/facts'.freeze

    def create_discovered_host(request)
      foreman_request = Proxy::HttpRequest::ForemanRequest.new
      req = foreman_request.request_factory.create_post(CREATE_DISCOVERED_HOST_PATH, request.body.read)
      response = foreman_request.send_request(req)
      unless response.is_a? Net::HTTPSuccess
        msg = JSON.parse(response.body)['message'] rescue "N/A"
        raise "Discovery failed, code #{response.code}, reason: #{msg}"
      end
    end

    def inventory_facter(ip)
      client = get_rest_client(generate_url(ip))
      client["/inventory/facter"].get
    end

    def refresh_facts_legacy(ip)
      client = get_rest_client(generate_url(ip))
      client['/facts'].get
    end

    def reboot_legacy(ip)
      url         = "http://#{ip}:8443"
      reboot_path = "/bmc/#{ip}/chassis/power/cycle"
      client      = get_rest_client(url)
      client[reboot_path].put({})
    end

    def reboot(ip)
      client = get_rest_client(generate_url(ip))
      client["/power/reboot"].put({})
    end

    def kexec(ip, body)
      client = get_rest_client(generate_url(ip))
      client["/power/kexec"].put(body)
    end

    private

    def generate_url(ip)
      scheme = Proxy::Discovery::Plugin.settings.node_scheme
      port = Proxy::Discovery::Plugin.settings.node_port
      "#{scheme}://#{ip}:#{port}"
    end

    def get_rest_client(url)
      RestClient::Resource.new(url, verify_ssl: OpenSSL::SSL::VERIFY_NONE)
    end
  end
end
