require 'test/unit'
require 'pp'

class TestBase < Test::Unit::TestCase
  @@test_template = {}
  def run(*args)
    return if(@method_name.to_s == "default_test")
    super
  end
  def self.start_test
    self.parse if(@@test_template.empty?)
    self.generate_tests 
  end
  private
  def self.parse
    test_name = ""
    buf = ""
    buf_mode = ""
    while line = DATA.gets do 
      line.chomp!
      if(line =~ /^(===|---)/)
        if(buf != "" && test_name != "" && buf_mode != "")
          @@test_template[test_name][buf_mode] = eval(buf)
          buf = ""
        end
        if(line =~ /^=== (.*)$/)
          test_name = $1
          @@test_template[test_name] = {}
        elsif(line =~ /--- input (.*)$/)
          @@test_template[test_name][:method_name] = $1
          buf_mode = :input
        elsif(line = ~/--- expected/)
          buf_mode= :expected
        end
      else
        buf += line
      end
    end
    if(buf != "" && test_name != "" && buf_mode != "")
      @@test_template[test_name][buf_mode] = eval(buf)
      buf = ""
    end
  end
  def self.generate_tests
    @@test_template.each do |test_name,test_args|
      define_method(test_name) do
        result=__send__(test_args[:method_name],test_args[:input])
        assert_equal test_args[:expected], result, " error on #{test_name}"
      end
    end 
  end
end
