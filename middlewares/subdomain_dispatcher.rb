# subdomain dispatching middleware
class Subdomain_Dispatcher

  def initialize(app,&block)
    @app = app
    @domains = {}
    @ssl = false
    @subs = []
    @errors = {
      ssl: ['403', {'Content-Type' => 'text/html'}, ['Forbidden, This resource is HTTPS only']]
    }
    @cors = {}
    @cors_default = "*"
    instance_exec(&block)
  end

  def ssl_only
    @ssl = true
    yield
    @ssl = false
  end

  def set_cors_to header, &check
    @cors[check] = header
  end

  def set domain,app
    @subs << (d = domain.to_s)
    @domains[d] = {
        app: app,
        ssl: @ssl
    }

  end

  def call(env)
    response = get_response(subdomain(env),env)
    response[1]['Access-Control-Allow-Origin'] = get_cors_header(env)
    response
  end



  private
  def subdomain(env)
    env['HTTP_HOST'].split('.').first
  end

  def get_cors_header(env)
    if a = @cors.detect do |check,cors|
        check.call(env)
      end
      a.last
    else
      @cors_default
    end
  end

  def get_response(sub,env)
    if @subs.include?(sub)
      if @domains[sub][:ssl]
        if env['rack.url_scheme'] == 'https'
          @domains[sub][:app].call(env)
        else
        @errors[:ssl]
        end
      else
        @domains[sub][:app].call(env)
      end
    else
      @app.call(env)
    end
  end

end
