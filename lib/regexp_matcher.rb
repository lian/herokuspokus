require "uri"

proc_match_lines = proc { |env| # "env_info"
	matcher = env["rack.request.query_hash"]["match"]
	lines = env["rack.request.query_hash"]["lines"]
	if lines && matcher
		exp = Regexp.new matcher
		lines.collect { |str|
		  (m = str.match(exp)) ? m.to_a : nil
    }.select { |l| l }
	else
		{ :error => "no lines or matcher given" }
	end
}

proc_match_html = lambda { |env| # "env_info"
  count ||= 0; count++
  _params = env["rack.request.query_hash"]

	return { :error => "no 'match' argument given" } unless _params["match"].is_a?(String)
	return { :error => "no 'urls' argument of type list given" } unless _params["urls"].is_a?(Array)
	return { :error => "too many urls given. max 5" } if  _params["urls"].size > 5

	urls = _params["urls"].collect { |i| URI.parse(i).to_s }
	if _params["match"] && urls
		exp = Regexp.new( _params["match"] )
		requests = urls.select { |i|
			begin
				open(i).to_s.match exp
			rescue Exception => e
				puts e.inspect
				nil
			end
		}
	end
}

Pokus.attach "match lines", proc_match_lines
Pokus.attach "match html", proc_match_html
