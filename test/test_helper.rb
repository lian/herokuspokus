ENV['RACK_ENV'] = 'test'

begin
  require 'rack'
rescue LoadError
  require 'rubygems'
  require 'rack'
end

testdir = File.dirname(__FILE__)
$LOAD_PATH.unshift testdir unless $LOAD_PATH.include?(testdir)
libdir = File.dirname(File.dirname(__FILE__)) # + '/lib'
$LOAD_PATH.unshift libdir unless $LOAD_PATH.include?(libdir)

#
#  require 'contest'
#  require 'rack/test'
#  require 'sinatra/base'
#  
#  class Sinatra::Base
#    # Allow assertions in request context
#    include Test::Unit::Assertions
#  end
#  
#  # Sinatra::Base.set :environment, :test
#  

require 'test/unit'


%w{json net/http uri}.each { |g| require g }
def json_api(_params={},_url='http://localhost:3000/')
  data = { :__json => _params.to_json }
  JSON.parse b=Net::HTTP.post_form(URI.parse(_url), data).body
rescue JSON::ParserError => e
  puts ['JSON::ParserError', e.message]; b
rescue Exception => e
  puts ['Exception', e.message];
end

task = {
  :__call => 'match lines',
  :match => '^a.', :lines => [ 'aab', 'aba', 'bab']
} #puts json_api(task).inspect
