proc_env_info = proc { |env| # "env_info"
  if env["rack.request.query_hash"].respond_to? :keys
    # /i?p => return ip
    if env["rack.request.query_hash"].keys.include?("p")
      return (ma = env["REMOTE_ADDR"].match(/^(.+), /)) ? ma[1] : env["REMOTE_ADDR"]
    end

     # /i?ua => return user_agent
    return env["HTTP_USER_AGENT"] if env["rack.request.query_hash"].keys.include?("ua")
     # /i?la => return accept_language
    return env["HTTP_ACCEPT_LANGUAGE"] if env["rack.request.query_hash"].keys.include?("la")
     # /i?t => return unix time
    return Time.now.to_i.to_s if env["rack.request.query_hash"].keys.include?("t")
     # /i?tf => return time as float
    return Time.now.to_f.to_s if env["rack.request.query_hash"].keys.include?("tf")
    # /i?c => return HTTP_COOKIE
    return env["HTTP_COOKIE"] if env["rack.request.query_hash"].keys.include?("c")
  end

  res = {
    "REMOTE_ADDR" => env["REMOTE_ADDR"],
    "HTTP_HOST" => env["HTTP_HOST"],
    "HTTP_USER_AGENT" => env["HTTP_USER_AGENT"],
    "HTTP_ACCEPT_LANGUAGE" => env["HTTP_ACCEPT_LANGUAGE"],
    "TIME" => Time.now.to_i
  }
  #Pokus.return_as res, env["pokus.return_as"]
}


Pokus.attach "env.info", proc_env_info

Pokus.attach("env.info.to_yaml") { |env|
  env.merge!({ "pokus.method" => "env.info"})
  JSON.parse(Pokus.call( env )).to_yaml
}
