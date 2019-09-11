# -*- coding: utf-8 -*-
$LOAD_PATH.push('./lib')
require 'test/test_base'
require 'pp'
require 'utils/fit_file_reader'

class T01FitUtilTest < Test::TestBase
  def setup
#    @root_path = Dir.pwd
    @logfile_name = './sample_resources/fit_log_file/irohazaka_renkouji_route.fit'
    @ffr = FitFileReader.new(@logfile_name)
  end
  def read_header(key)
    @ffr.get_header(key)
  end
  def extract_to_json(keys)
    @ffr.export_record(keys,"./sample_resources/json_file/test01")
    return File.exist?("./sample_resources/json_file/test01.json")
  end
end
T01FitUtilTest.start_test
__END__
=== test_can_read_header:header_size
--- input read_header
:header_size
--- expected
0x0e
=== test_can_export_record:lat,long
--- input extract_to_json
[:position_lat, :position_long]
--- expected
true
