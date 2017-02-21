require 'json'
class Json_Auto_Parse

  def initialize(app)
    @app = app
  end


  def call(env)
    if env['CONTENT_TYPE'] =~ /json/
      env['JSON'] = JSON.parse( req.body.read )
    end
    @app.call(env)
  end

end
