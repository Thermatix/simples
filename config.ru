#\ -s puma -o 127.0.0.1 -p 3000 -O Threads=0:16 -O Verbose

file = __FILE__
[File.dirname(file),File.expand_path('../app', file),File.expand_path('../lib', file)].each do |dir|
  $LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)
end

require 'yaml'
# require 'rack-livereload'
require 'puma'

config = {}
YAML.load(File.open(File.join(File.dirname(__FILE__), 'config.yml'))).each do |config_group, options|
  case config_group
  when :config
    options.each do |key,value|
      config[key.to_sym] = value
    end
  when :envs
    if options
      options.each do |key,value|
        ENV[key.to_s] = value
      end
    end
  end
end

require './middlewares/manifest'
require 'app_autoloader'


Sinatra::Application.reset!
# use Rack::Reloader
use Rack::Deflater
use Rack::Session::Cookie, :key => config[:cookie][:key],
                           :path => config[:cookie][:key],
                           :secret => Digest::SHA1.hexdigest(rand.to_s)
use Headers
use X_Headers
# use Rack::LiveReload,config[:live_reload]

use Json_Auto_Parse

use Subdomain_Dispatcher do
  set_cors_to '*localhost*'do |env|
    ENV['APP_ENV'] == 'dev'
  end
  set 'api', API
  set 'headers', Headers
  set 'x-headers', X_Headers
end


# Rack::Builder = Rack::Handler.pick(config[:server][:handler])
# run App, config[:server][:config]
# run Rack::Handler.pick(config[:server][:handler]).run(App,config[:server][:config]).to_app
map '/api' do
  run API
end

run App


