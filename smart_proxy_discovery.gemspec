require File.expand_path('../lib/smart_proxy_discovery/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'smart_proxy_discovery'
  s.version = Proxy::Discovery::VERSION

  s.summary = 'Smart proxy discovery plugin'
  s.description = 'Smart proxy discovery plugin'
  s.authors = ['Shlomi Zadok']
  s.email = 'szadok@redhat.com'
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.files = Dir['{lib,settings.d,bundler.d}/**/*'] + s.extra_rdoc_files
  s.homepage = 'http://github.com/theforeman/smart_proxy_discovery'
  s.license = 'GPLv3'

  s.add_runtime_dependency('rack-contrib')
  s.add_runtime_dependency('rest-client')
end
