# -*- coding: utf-8 -*-
# Fit file definition can be download from
# https://www.thisisant.com/developer/resources/software-tools/

require 'time'

class FitFileReader
  def initialize(file_name)
    @logfile = File.open(file_name,"rb")
    @header_structure = [
      [:header_size , 'C',1],
      [:protocol_version, 'C',1],
      [:profile_version, 'v',2],
      [:data_size, 'V',4],
      [:data_type_byte, 'V',4],
      [:crc, 'v',2],
    ]
    @header ={}
    @record_first_byte = [
      [:normal_header , 'C',1], #0x40. Definition Header #<0x40 data header
    ]
    @record_header_structure = [
      [:reserved, 'C',1],
      [:architecture, 'C',1], #0:little endian, 1:big endian. This time little endian only
      [:global_message_number, 'v',2], # on my fit sample, used message numbers are
# file_id 0 (1 record), file_creator	49 (1),timestamp_correlation	162 (1),device_info	23 (3), record	20 (2351), event	21 (3),lap	19 (3),session	18 (1),activity	34(1)
      [:fields, 'c',1],
    ]
    @rec_head ={}
    @record_def ={}
    @record_definition = [
      [:field_definition_number, 'C',1],
      [:size, 'C',1], #byte
      [:base_type, 'C',1],
    ]
    @record_log = []
    @rec_counts = {}
    @fields_definition = {
      5 => 
      {
        253 => {:name => :timestamp, :func => lambda{|value| Time.at(628473600 + value).to_s } },
         0 => {:name => :position_lat, :func => lambda{|value| value * ( 180.0 / (2**31) ) } }, # semicircles to degree
         1 => {:name => :position_long, :func => lambda{|value| value * ( 180.0 / (2**31) ) } },
         5 => {:name => :distance, :func => lambda {|value| value/100.0}},
         29 => {:name => :accumulated_power, :func => lambda{|value| (value == 0xffffffff)? "na":value}},
         2 => {:name => :altitude, :func => lambda{|value| value/5.0 - 500.0}},
         6 => {:name => :speed, :func => lambda{|value| value/1000000.0 * 60 * 60}}, #km/h
         7 => {:name => :power, :func => lambda{|value| (value == 0xffff)? "na": value}}, 
         9 => {:name => :grade, :func => lambda{|value| (value == 0x7fff)? "na": value/100.0}}, 
         33 => {:name => :calories,}, 
         3 => {:name => :heart_rate, }, 
         4 => {:name => :cadence, }, 
         13 => {:name => :temperature, }, 
         30 => {:name => :left_right_balance, :func => lambda{|value| (value == 0xff)? "na": value}}, 
         43 => {:name => :left_torque_effectiveness, :func => lambda{|value| (value == 0xff)? "na": value/2.0}}, 
         44 => {:name => :right_torque_effectiveness, :func => lambda{|value| (value == 0xff)? "na": value/2.0}}, 
         45 => {:name => :left_pedal_smoothness, :func => lambda{|value| (value == 0xff)? "na": value/2.0}}, 
         46 => {:name => :right_pedal_smoothness, :func => lambda{|value| (value == 0xff)? "na": value/2.0}}, 
      }
    }
    parse_all
  end
  def calc_scale_offset(rec) 
    rec.keys.each do |k|
      if(@fields_definition[5].has_key?(k))
        tmp = (@fields_definition[5][k].has_key?(:func)) ? @fields_definition[5][k][:func].call(rec[k]) : rec[k]
        rec[k] = {:name => @fields_definition[5][k][:name], :value => tmp} 
      end
    end
  end
  def parse_all
    parse(@header_structure,@header)
    while(@logfile.eof != true) do
      parse(@record_first_byte,@rec_head)
      if(@rec_head[:normal_header] & 0x40 !=0) # num[pos] !=0 will work also.
        rec_id = @rec_head[:normal_header] ^ 0x40
        @record_def[rec_id] = {}
        parse(@record_header_structure,@record_def[rec_id])
        @record_def[rec_id][:def]=[]
        (0...@record_def[rec_id][:fields]).each do |i|
          @record_def[rec_id][:def][i] = {}
          parse(@record_definition,@record_def[rec_id][:def][i])
        end
        @record_def[rec_id][:rec_size] = @record_def[rec_id][:def].map{|r| r[:size]}.inject(:+)
#        puts "definition"
#        pp rec_id.to_s(16)
        @rec_counts[rec_id]=0
        if(rec_id == 5)
          pp [rec_id, @record_def[rec_id]]
        else
#          pp [rec_id, @record_def[rec_id][:global_message_number]]
        end
#        puts "definition end"
      else
#        puts "data"
#        pp @rec_head[:normal_header].to_s(16)
        if(@record_def[@rec_head[:normal_header]] == nil)
#          pp "no_record\n"
          break
        else
#          pp @record_def[@rec_head[:normal_header]][:rec_size]
          if(@record_def[@rec_head[:normal_header]][:global_message_number] == 20)
            parse_record_field(@record_def[@rec_head[:normal_header]][:rec_size], @record_log)
          else
            yomitobashi(@record_def[@rec_head[:normal_header]][:rec_size])
            @rec_counts[@rec_head[:normal_header]] = @rec_counts[@rec_head[:normal_header]] + 1 
          end
        end
      end
    end
  pp @rec_counts
  end
  def yomitobashi(size)
    @logfile.read(size)
  end
  def parse_record_field(size, log)  # for global message number 20
    a = @logfile.read(size).unpack("L<l<l<L<L<S<S<S<s<s<CCcCCCCC")
    tmp = Hash[*[253,0,1,5,29,2,6,7,9,33,3,4,13,30,43,44,45,46].zip(a).flatten(1)]
#    tmp = Hash[*[:timestamp,:position_lat,:position_long,:distance,:accumulated_power,:altitude,:speed,:power,:grade,:calories,:heart_rate,:cadence,:temperature,:left_right_balance,:left_torque_effectiveness,:right_torque_effectiveness,:left_pedal_smoothness,:right_pedal_smoothness].zip(a).flatten(1)]
    if(tmp[253] == 936822666)
      calc_scale_offset(tmp)
      pp tmp
    end

#    pp tmp[:position_long]
    log.push(tmp)
  end
  def parse(struct, result)
    unpack_string = struct.map{|v| v[1]}.join
    length = struct.map{|v| v[2]}.inject(:+)
    value = @logfile.read(length).unpack(unpack_string)
    value.each_index do |i|
      result[struct[i][0]] = value[i]
    end
  end
  def get_header(key)
    @header[key]
  end
  def get_record(key)
    @header[key]
  end
end
