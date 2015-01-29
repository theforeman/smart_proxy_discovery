require 'smart_proxy_discovery/version'
require 'smart_proxy_discovery/discovery'

# Temporary patch to fix the Client SSL issue (remove once it is fixed properly:
# http://projects.theforeman.org/issues/9089). We are taking advantage of the fact
# that this code gets executed before 'sinatra/ssl_client_verification'. The logic
# is to define the before filter first, and then disable it during the first
# request in runtime by removing it from the array directly.
::Sinatra::Base.helpers ::Proxy::Helpers
::Sinatra::Base.helpers ::Proxy::Log
::Sinatra::Base.before do
  unless request.env['REQUEST_PATH'] =~ /^\/discovery/
    if ['yes', 'on', '1'].include? request.env['HTTPS'].to_s
      if request.env['SSL_CLIENT_CERT'].to_s.empty?
        log_halt 403, "No client SSL certificate supplied"
      end
    else
      logger.debug('require_ssl_client_verification: skipping, non-HTTPS request')
    end
  end
  # remove the original filter which was added
  ::Sinatra::Base.filters[:before].pop if ::Sinatra::Base.filters[:before].count > 1
end
