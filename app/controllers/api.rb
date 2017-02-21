require 'grape'
require 'json'
class API < Grape::API
  format :json
  get '/hello' do
    {hello: "world"}
  end
end
