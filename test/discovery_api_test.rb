require 'test_helper'

require 'smart_proxy_discovery'
require 'smart_proxy_discovery/discovery_api'

ENV['RACK_ENV'] = 'test'

class DiscoveryApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ::Proxy::Discovery::Api.new
  end

  def setup
    @foreman_url = 'https://foreman.example.com'
    Proxy::SETTINGS.stubs(:foreman_url).returns(@foreman_url)
    @facts = {
      "ipaddress" => "192.168.100.42",
      "macaddress" => "AA:BB:CC:DD:EE:FF",
      "discovery_bootif" => "AA:BB:CC:DD:EE:FF",
    }
    @discovered_node = '192.168.100.42'
  end

  def test_create_facts_success
    stub_request(:post, "#{@foreman_url}/api/v2/discovered_hosts/facts")
    post "/create", @facts
    assert_empty last_response.body
    assert last_response.successful?
  end

  def test_create_facts_failure
    stub_request(:post, "#{@foreman_url}/api/v2/discovered_hosts/facts")
      .to_return(:body => '{"status": "error", "message": "blah"}', :status => 500)
    post "/create", @facts
    assert_equal 500, last_response.status
  end

  def test_refresh_facts_success
    stub_request(:get, "http://#{@discovered_node}:8443/facts")
    get "/#{@discovered_node}/facts"
    assert_empty last_response.body
    assert last_response.successful?
  end

  def test_refresh_facts_failure
    stub_request(:get, "http://#{@discovered_node}:8443/facts")
      .to_return(:body => '{"status": "error", "message": "blah"}', :status => 500)
    get "/#{@discovered_node}/facts"
    assert_equal 500, last_response.status
  end

  def test_reboot_success
    stub_request(:put, "http://#{@discovered_node}:8443/bmc/#{@discovered_node}/chassis/power/cycle")
    put "/#{@discovered_node}/reboot"
    assert_empty last_response.body
    assert last_response.successful?
  end

  def test_reboot_failure
    stub_request(:put, "http://#{@discovered_node}:8443/bmc/#{@discovered_node}/chassis/power/cycle")
      .to_return(:body => '{"status": "error", "message": "blah"}', :status => 500)
    put "/#{@discovered_node}/reboot"
    assert_equal 500, last_response.status
  end

end
