# -*- coding: utf-8 -*-
$LOAD_PATH.push('./lib')
require 'test/test_base'
require 'pp'
require 'make_view'

class T02MakeViewTest < Test::TestBase
  def setup
    @log_root = File.expand_path("./")
    @mv = MakeView.new(@log_root)
  end
  def created_json_has_keys(key)
    @mv.read_log(key)
    js = @mv.get_json
    js.keys.sort
  end
  def check_json_contents(key)
    file, content = *key
    @mv.read_log(file)
    js = @mv.get_json
    return js[content]
  end
  def make_html(key)
    @mv.read_log(key)
    @mv.make_html
  end

end
T02MakeViewTest.start_test
__END__
=== test_can_make_json
--- input created_json_has_keys
"data1"
--- expected
[:title, :midpoint, :route_data, :start, :end].sort
=== test_json_contents
--- input check_json_contents
["data1", :midpoint]
--- expected
[35.66321248188615, 139.44987083785236]
=== test_can_make_html
--- input make_html
"data1"
--- expected
true
