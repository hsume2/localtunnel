require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('localtunnel', '0.3') do |p|
  p.description    = "instant public tunnel to your local web server"
  p.url            = "http://github.com/progrium/localtunnel"
  p.author         = "Jeff Lindsay"
  p.email          = "jeff.lindsay@twilio.com"
  p.has_rdoc       = false
  p.rdoc_pattern   = //
  p.rdoc_options   = []
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.executable_pattern = ["bin/*"]
  p.runtime_dependencies = ["json >=1.2.4", "net-ssh >=2.0.22", "net-ssh-gateway >=1.0.1", "sinatra >=1.2.6", "POpen4 >=0.1.4", "twilio-ruby >=3.2.0"]
  p.development_dependencies = []
end
