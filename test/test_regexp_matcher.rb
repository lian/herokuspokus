require File.dirname(__FILE__) + '/test_helper'
require "herokus-pokus"
require "lib/" + File.basename(__FILE__).gsub('test_','')

class RegexpMatcherTest < Test::Unit::TestCase 

   def test_match_lines_1
     env = {
       "pokus.method" => "match lines",
       "rack.request.query_hash" => {
         "match" => "(t|a|b)a$",
         "lines" => ["ta", "ta ", "aa", "ca", "ab", "ba" ]
       }
     }
     assert_equal Pokus.call(env), [ ["ta", "t"], ["aa", "a"], ["ba", "b"] ]
   end

   def test_match_lines_2
     env = {
       "pokus.method" => "match lines",
       "rack.request.query_hash" => {
         "match" => "^(.+?): (.+)$",
         "lines" => ["foo: bar", "fo o: ba r", "fo o:bar"]
       }
     }
     assert_equal Pokus.call(env), [ ["foo: bar", 'foo', 'bar'], ["fo o: ba r", "fo o", "ba r"] ]
   end
   
   def test_match_lines_3
     env = {
       "pokus.method" => "match lines",
       "rack.request.query_hash" => {
         "match" => "foo",
         "lines" => ["foo bar", "foo ", "bar"]
       }
     }
     # ! assert_equal on_match_lines(req), [ ["foo bar"], ["foo"] ]
     assert_equal Pokus.call(env), [ ["foo"], ["foo"] ]
   end
      
   def test_match_lines_no_matcher_or_lines
     env = {
       "pokus.method" => "match lines",
       "rack.request.query_hash" => {
         "lines" => ["foo bar", "foo ", "bar"]
       }
     }
     assert_equal Pokus.call(env), { :error => "no lines or matcher given" }
                                                   
     env = {
       "pokus.method" => "match lines",
       "rack.request.query_hash" => {
         "match" => "(t|a|b)a$"
       }
     }
     assert_equal Pokus.call(env), { :error => "no lines or matcher given" }
   end
   
end
