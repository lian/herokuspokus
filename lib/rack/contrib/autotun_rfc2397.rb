begin
  require 'base64'
rescue LoadError => e
  puts "no base64 found.. huh?"
end

module Rack
  #
  # Rack Middleware - which 'auto'-replaces targeted files and
  # inlines them via src="data:[<mediatype>][;base64],<data>"
  # the "data" URL scheme - http://www.ietf.org/rfc/rfc2397.txt
  #
  # TODO: different name?
  # TODO: make it more re-usable..
  # TODO: auto-proxy/inline extern images (tunnel)
  # TODO: remove content_type course safari/firefox doesnt use it.
  # TODO: implement def clean_cache!
  #
  # USAGE Examples:
  # use Rack::AutoTunRFC2397, :files => [ "test.jpg", "bg_toolbar.gif" ]
  # use Rack::AutoTunRFC2397, :static_encoded => { "tiny_icon.jpg" => "ZmFrZV91bmVuY29kZ .." }
  #
  # ADDITIONAL:
  # in html-response do: <img src="my/path/foo_image.jpg?dataURL" /> - is missing!
  #
  class AutoTunRFC2397
    F = ::File
    def initialize(app, opts={})
      @app, @opts = app, opts
      @files = opts[:files] || []
      @static_encoded = opts[:static_encoded] || {}
      @encode_cache = opts[:cache] || { }
    end

    def call(env)
      status, headers, body = @app.call env
      
      if status == 200 && headers["Content-Type"] == "text/html"
        body = html_replace_dataurls body
        headers.delete 'Content-Length'; clean_cache!
      end
      
      [status, headers, body]
    end


    # private
    def encode_file!(content_str,content_type="image/jpeg")
      begin
        "data:#{content_type};base64,"+ \
        ::Base64.encode64( content_str ).select{|l| l.chop!}.join('')
      rescue Exception
        "data:#{content_type};base64,null" # or return 'filename' instead?
      end
    end

    def data_url(filename, _type="image/jpeg")
      @encode_cache[filename] ||= encode_file! filename, _type
    end

    def html_replace_dataurls(html_body)
      html_body.collect do |str|
        str.scan(/src=\"(.*?)\"/).collect { |i| i.to_s.split("?")[0] }.select { |i| @files.include?(i) || @static_encoded[i] }.each { |file_path|
          if _data = @static_encoded[file_path] || @encode_cache[file_path] || read_file(file_path)
            str.gsub! "src=\"#{file_path}", "src=\"" + data_url( _data, "image/#{F.extname(file_path)[1..-1]}" )
          end
        }
        str
      end
    end

    def read_file(f)
      F.open("public/"+f).read
    rescue Exception
      nil
    end
    def clean_cache!; true; end
  end

end #Rack

