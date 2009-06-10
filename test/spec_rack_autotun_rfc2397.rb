begin
  require 'test/spec'  
rescue Exception
  require 'rubygems'
  require 'test/spec'
ensure
  require 'rack/mock'
end

require File.dirname(__FILE__)+"/../lib/rack/contrib/autotun_rfc2397"


context "Rack::AutoTunRFC2397" do

  def request(app)
    opts = { :static_encoded => { "test.jpg" => "fake_unencoded_bas64_content" } }
    response = Rack::AutoTunRFC2397.new(app,opts).call({})
  end

  specify "matched image/data inlines itself as data-URL (base64 encoded) automatically on html-responses" do
    app = lambda { |env| [200, {'Content-Type' => 'text/html'}, "<img src=\"test.jpg\" /> "] }
    response = request app
    
    response.should.equal [200, {"Content-Type"=>"text/html"},
      ["<img src=\"data:image/jpg;base64,ZmFrZV91bmVuY29kZWRfYmFzNjRfY29udGVudA==\" /> "]  ]
  end

  specify "should not touch unknown/unmarked images" do
    app = lambda { |env| [200, {'Content-Type' => 'text/html'}, "<img src=\"other.jpg\" /> "] }
    response = request app
    
    response.should.equal [200, {"Content-Type"=>"text/html"},
      ["<img src=\"other.jpg\" /> "]  ]
  end

  specify "should only process text/html" do
    _env = [302, {'Content-Type' => 'text/plain'}, "<img src=\"test.jpg\" /> "]
    response = request lambda { |env| _env }
    response.should.equal _env
  end
  
  specify "should only process status 200" do
    _env = [0, {}, []]
    response = request lambda { |env| _env }
    response.should.equal _env

    _env = [404, {}, []]
    response = request lambda { |env| _env }
    response.should.equal _env
    
    _env = [302, {'Content-Type' => 'text/html'}, "<img src=\"test.jpg\" /> "]
    response = request lambda { |env| _env }
    response.should.equal _env
  end

end
