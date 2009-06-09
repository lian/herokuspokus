require File.dirname(__FILE__) + '/test_helper'
require "herokus-pokus"
require "lib/" + File.basename(__FILE__).gsub('test_','')

class PokusUtilsTest < Test::Unit::TestCase 
  def setup
    @res_keys = %w{HTTP_USER_AGENT HTTP_ACCEPT_LANGUAGE HTTP_HOST REMOTE_ADDR TIME}
  end
  
  def test_pokusmethod_env_info
    res = Pokus.call( { "pokus.method" => "env.info" } )
    
    assert res.respond_to?(:keys)
    @res_keys.each { |k| assert_equal res.keys.include?(k), true }
  end
  
end
