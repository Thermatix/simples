class X_Headers < Headers

  def call(env)
    super(env,'X-HEADERS')
  end

  def self.get_headers(env)
    super(env,'X-HTTP')
  end

  def self.call(env)
    super(env,'X-HEADERS')
  end

end
