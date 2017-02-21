class Headers

  def initialize(app=nil)
    @app = app
  end

  def call(env,key='HEADERS')
    env[key] = self.class.get_headers(env)
    @app.call(env)
  end

  def self.get_headers(env,start="HTTP")
       env.select {|k,v| k.start_with? "#{start}_"}.
         inject({}) {|h,(k,v)| h[k.sub(/^#{start}_/,'').downcase.to_sym] = v;h }
  end

  def self.call(env,key='HEADERS')
    ['200',{ 'Content-Type'=> 'application/json' },[(env.fetch(key){get_headers(env)}.merge(env)).to_json]]
  end

end



