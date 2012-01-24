require 'sinatra/base'

class LocalTunnel::Tunnel
  class TunnelApp < Sinatra::Base
    class << self
      attr_accessor :tunnel
    end

    set :port, (ENV['LOCAL_TUNNEL_PORT'] || 9000)

    get '/' do
      TunnelApp.tunnel
    end
  end
end
