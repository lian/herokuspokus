#require "rubygems"
#require "rack"
class Pokus
  def self.attach(name, _fn=nil, &bl)
    return nil unless (_fn.respond_to? :call || block_given?)
    @@mtree ||= {} # @@mtree[nil] = nil
    @@mtree[name] = (_fn || bl)
  end
  def self.detach(name); @@mtree.delete name; end
  def self._methods(name); @@mtree; end

  def self.call(env={})
    env["rack.request.query_hash"] ||= {}
    # req = Rack::Request.new env

    if json = env["rack.request.query_hash"] && env["rack.request.query_hash"]["__json"]
      env["rack.request.query_hash"].merge! JSON.parse( json )
      env["rack.request.query_hash"].delete "__json"
    end
    if json = env["rack.request.form_hash"] && env["rack.request.form_hash"]["__json"]
      env["rack.request.form_hash"].merge! JSON.parse( json )
      env["rack.request.form_hash"].delete "__json"
    end
    
    
    env["rack.request.query_hash"].keys.each { |k|
      if k.match(/__(call|method|action|send|invoke|do)$/)
        env["pokus.method"] = env["rack.request.query_hash"][k]; break
      end
    }

    m_key = env["pokus.method"] || env["rack.request.method"]
    
    if _method = @@mtree[ m_key ]
      begin
        res = _method.call env
      rescue Exception => e
        puts [e.message, e.backtrace]
        return { :exception => e.message, :when => Time.now, :params => [req.params, env["pokus.method"]] }
      ensure
        return res
      end
     else
       return nil
    end
  end

  # def self.return_as(res, _format="s") # not used..
  #   m_key = "to_#{_format}".to_sym
  #   res.respond_to?(m_key) ? res.send(m_key) : res
  # end
end


require "json"
class PokusMiddleware
  def initialize(_app, _options={})
    @app, @options = _app, _options
  end

  def call( env={} )
    if res = Pokus.call( env )
      _json = res.to_json
      [200, { "Content-Type" => "text/json", "Content-Length" => "#{_json.size}", }, _json]
    else
      @app.call(env)
    end
  end

  def self.invoke env={}, opt={}
    @@instance ||= new opt; @@instance.call env
  end
end



begin
  require "lib/regexp_matcher"
  require "lib/pokus-utils"
  $index_page ||= File.read("README")
  $__main = self
rescue Exception => e
  $index_page ||= "hocus pocus iunior \nload-error: #{e.message}"
end

require "sinatra"
require "lib/rack/contrib/autotun_rfc2397"
require "lib/rack/contrib/bounce_favicon"

use Rack::ContentLength
use Rack::BounceFavicon
use PokusMiddleware
use Rack::AutoTunRFC2397, :files => [ "_icon.jpg", "pixel.gif" ] #, :force => true, :extern => true

get "/" do
  content_type "text/plain"
  $index_page.gsub("pocus iunior","pocus iunior / #{$__main.object_id}:#{Time.now.to_f.to_s}")
end

get "/" do
  content_type "text/plain"
  $index_page.gsub("pocus iunior","pocus iunior / #{$__main.object_id}:#{Time.now.to_f.to_s}")
end

get "/i" do
  content_type "text/plain"
  res = Pokus.call( env.merge("pokus.method" => "env.info") )
  res.is_a?(String) ? res : res.to_yaml
end


get "/autotun_rfc2397" do
  %{
    <h1>Rack::AutoTunRFC2397</h1>
    <h2>rack/contrib/autotun_rfc2397: "data" URL scheme - http://www.ietf.org/rfc/rfc2397.txt</h2>

    <p>'auto'-replaces targeted files and inline them via src="data:[<mediatype>][;base64],<data>" </p>

    <p>
    use Rack::AutoTunRFC2397, :files => [ "header.jpg", "bg_toolbar.gif" ] <br />
    use Rack::AutoTunRFC2397, :static_encoded => { "tiny_icon.jpg" => "ZmFrZV91bmVuY29kZ .." }
    </p>

    <div style="text-align:center">
      <img src="openbsd_vistaincapable.png" /><br />
      <img src="pixel.gif" /><br />
      <img src="_icon.jpg" /><br />
    </div>
  }
end
