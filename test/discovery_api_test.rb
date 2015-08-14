require 'test_helper'

require 'smart_proxy_discovery'
require 'smart_proxy_discovery/discovery_api'

ENV['RACK_ENV'] = 'test'

class DiscoveryApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ::Proxy::Discovery::Dispatcher.new
  end

  def setup
    @foreman_url = 'https://foreman.example.com'
    Proxy::SETTINGS.stubs(:foreman_url).returns(@foreman_url)
    Proxy::Discovery::Plugin.settings.stubs(:node_scheme).returns('https')
    Proxy::Discovery::Plugin.settings.stubs(:node_port).returns('8443')
    @facts = {
      "ipaddress" => "127.0.0.2",
      "macaddress" => "AA:BB:CC:DD:EE:FF",
      "discovery_bootif" => "AA:BB:CC:DD:EE:FF",
    }
    @discovered_node_ip = '127.0.0.2'
    @discovered_node_url = "https://#{@discovered_node_ip}:8443"
    @discovered_node_url_legacy = "http://#{@discovered_node_ip}:8443"
  end

  def test_create_facts_success
    stub_request(:post, "#{@foreman_url}/api/v2/discovered_hosts/facts")
    post "/create", @facts
    assert last_response.body.empty?
    assert last_response.successful?
  end

  def test_create_facts_failure
    stub_request(:post, "#{@foreman_url}/api/v2/discovered_hosts/facts").to_return(:body => '{"status": "error", "message": "blah"}', :status => 500)
    post "/create", @facts
    assert_equal 500, last_response.status
    assert_match(/^Discovery failed.*blah/, last_response.body)
  end

  def test_refresh_facts_success
    stub_request(:get, "#{@discovered_node_url}/facts").to_return(:body => 'ok', :status => 200)
    get "/#{@discovered_node_ip}/facts"
    assert_equal 200, last_response.status
    assert_equal "ok", last_response.body
  end

  def test_refresh_facts_failure
    stub_request(:get, "#{@discovered_node_url}/facts").to_return(:body => 'bad', :status => 500)
    get "/#{@discovered_node_ip}/facts"
    assert_equal 500, last_response.status
    assert_match /Proxy error .* bad/, last_response.body
  end

  def test_reboot_legacy_success
    stub_request(:put, "#{@discovered_node_url_legacy}/bmc/#{@discovered_node_ip}/chassis/power/cycle").to_return(:body => 'ok', :status => 200)
    put "/#{@discovered_node_ip}/reboot"
    assert_equal 200, last_response.status
    assert_equal "ok", last_response.body
  end

  def test_reboot_legacy_failure
    stub_request(:put, "#{@discovered_node_url_legacy}/bmc/#{@discovered_node_ip}/chassis/power/cycle").to_return(:body => 'bad', :status => 500)
    put "/#{@discovered_node_ip}/reboot"
    assert_equal 500, last_response.status
    assert_match /Proxy error .* bad/, last_response.body
  end

  def test_reboot_success
    stub_request(:put, "#{@discovered_node_url}/power/reboot").to_return(:body => 'ok', :status => 200)
    put "/#{@discovered_node_ip}/power/reboot"
    assert_equal 200, last_response.status
    assert_equal "ok", last_response.body
  end

  def test_reboot_failure
    stub_request(:put, "#{@discovered_node_url}/power/reboot").to_return(:body => 'bad', :status => 500)
    put "/#{@discovered_node_ip}/power/reboot"
    assert_equal 500, last_response.status
    assert_match /Proxy error .* bad/, last_response.body
  end

  def test_kexec_success
    stub_request(:put, "#{@discovered_node_url}/power/kexec").to_return(:body => 'ok', :status => 200)
    put "/#{@discovered_node_ip}/power/kexec"
    assert_equal 200, last_response.status
    assert_equal "ok", last_response.body
  end

  def test_kexec_failure
    stub_request(:put, "#{@discovered_node_url}/power/kexec").to_return(:body => 'bad', :status => 500)
    put "/#{@discovered_node_ip}/power/kexec"
    assert_equal 500, last_response.status
    assert_match /Proxy error .* bad/, last_response.body
  end
end
