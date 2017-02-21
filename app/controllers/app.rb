require 'sinatra'
require 'helpers'
class App < Sinatra::Base
  configure do
    set :root, APP_ROOT
    set :public_folder, "#{APP_ROOT}/public"
  end
  helpers Helpers

  get('/') do
    erb :index
  end

  get(/[^\/]/) do
    erb :index
  end
end
