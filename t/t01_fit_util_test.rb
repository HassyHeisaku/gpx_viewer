# -*- coding: utf-8 -*-
$LOAD_PATH.push('./lib')
require 'test/test_base'
require 'pp'
require 'utils/fit_file_reader'

class T01FitUtilTest < Test::TestBase
  def setup
#    @root_path = Dir.pwd
    @logfile_name = './sample_resources/log_file/irohazaka_renkouji_route.fit'
    @ffr = FitFileReader.new(@logfile_name)
  end
  def read_header(key)
    @ffr.get_header(key)
  end
end
T01FitUtilTest.start_test
#94208 - 14
__END__
=== test_can_read_header:header_size
--- input read_header
:header_size
--- expected
0x0e
