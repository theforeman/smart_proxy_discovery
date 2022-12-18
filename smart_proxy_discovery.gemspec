require File.expand_path('../lib/smart_proxy_discovery/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'smart_proxy_discovery'
  s.version = Proxy::Discovery::VERSION

  s.summary = "Discovery plugin for Foreman's smart proxy"
  s.description = 'This smart proxy plugin, together with a Foreman plugin, add the capability to discover unknown bare-metal. This plugin provides proxy API for nodes to communicate with Foreman instance and vice versa.'
  s.authors = ['Shlomi Zadok']
  s.email = 'szadok@redhat.com'
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.files = Dir['{lib,settings.d,bundler.d}/**/*'] + s.extra_rdoc_files
  s.homepage = 'https://github.com/theforeman/smart_proxy_discovery'
  s.license = 'GPLv3'

  s.required_ruby_version = '>= 2.5', '< 4'

  s.add_development_dependency('test-unit')
  s.add_development_dependency('rake')
  s.add_development_dependency('rack')
  s.add_development_dependency('rack-test')
  s.add_development_dependency('mocha')
  s.add_development_dependency('webmock')

  s.add_runtime_dependency('rest-client')
end
