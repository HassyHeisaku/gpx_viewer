# -*- coding: utf-8 -*-
$LOAD_PATH.push('./lib')
require 'test/test_base'
require 'pp'
require 'utils/fit_file_reader'

class T01FitUtilTest < Test::TestBase
  def read_header(arg)
    logname, key = arg
    @ffr = FitFileReader.new(logname)
    @ffr.get_header(key)
  end
  def all_process(args)
    logname, keys, filename = *args
    @ffr = FitFileReader.new(logname)
    @ffr.export_record(keys,filename)
    return File.exist?("#{filename}.json")
  end
end
T01FitUtilTest.start_test
__END__
=== test_can_read_header:header_size
--- input read_header
['./private_data/fit_log_file/irohazaka_renkouji_route.fit', :header_size]
--- expected
0x0e
=== test_can_export_record:lat,long
--- input all_process
['./private_data/fit_log_file/irohazaka_renkouji_route.fit',[:position_lat, :position_long], "./private_data/json_file/test01"]
--- expected
true
=== test_all_process:
--- input all_process
["./private_data/fit_log_file/yamanakako_route.fit" , [:position_lat, :position_long], "./private_data/json_file/test02"]
--- expected
true
