require 'rubygems'
require 'net/ssh'
require 'net/ssh/gateway'
require 'net/http'
require 'uri'
require 'json'
require 'open4'

require 'localtunnel/net_ssh_gateway_patch'

module LocalTunnel; end

require 'localtunnel/tunnel_app'

class LocalTunnel::Tunnel

  SHELL_HOOK_FILE = "./.localtunnel_callback"

  attr_accessor :port, :key, :host

  def initialize(port, key)
    @port = port
    @key  = key
    @host = ""
  end

  def register_tunnel(key=@key)
    url = URI.parse("http://open.localtunnel.com/")
    if key
      resp = JSON.parse(Net::HTTP.post_form(url, {"key" => key}).body)
    else
      resp = JSON.parse(Net::HTTP.get(url))
    end
    if resp.has_key? 'error'
      puts "   [Error] #{resp['error']}"
      exit
    end
    @host = resp['host'].split(':').first
    @tunnel = resp
    return resp
  rescue
    puts "   [Error] Unable to register tunnel. Perhaps service is down?"
    exit
  end

  def start_tunnel
    port = @port
    tunnel = @tunnel

    TunnelApp.tunnel = tunnel['host']
    tunnel_pid = fork { TunnelApp.run! }

    at_exit do
      Process.kill('KILL', tunnel_pid)
      Process.waitpid(tunnel_pid)
    end

    error = ''

    status = Open4::popen4("ssh -nNT -g -R *:#{tunnel['through_port']}:0.0.0.0:#{port} #{tunnel['user']}@#{@host} -o PasswordAuthentication=no") do |pid, i, o, e|
      puts "   " << tunnel['banner'] if tunnel.has_key? 'banner'
      if File.exists?(File.expand_path(SHELL_HOOK_FILE))
        system "#{SHELL_HOOK_FILE} ""#{tunnel['host']}""" if File.exists?(File.expand_path(SHELL_HOOK_FILE))
        if !$?.success?
          puts "   An error occurred executing the callback hook #{SHELL_HOOK_FILE}"
          puts "   (Make sure it is executable)"
        end
      end
      puts "   Port #{port} is now publicly accessible from http://#{tunnel['host']} ..."

      begin
        while str = e.gets
          error += str
          puts str
        end
      rescue Interrupt
        exit
      end
    end

    if error =~ /Permission denied/
      possible_key = Dir[File.expand_path('~/.ssh/*.pub')].first
      puts "   Failed to authenticate. If this is your first tunnel, you need to"
      puts "   upload a public key using the -k option. Try this:\n\n"
      puts "   localtunnel -k #{possible_key ? possible_key : '~/path/to/key'} #{port}"
      exit
    end
  end
end
