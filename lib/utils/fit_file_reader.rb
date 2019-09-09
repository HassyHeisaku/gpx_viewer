# -*- coding: utf-8 -*-
# Fit file definition can be download from
# https://www.thisisant.com/developer/resources/software-tools/

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
      [:global_message_number, 'v',2], # treat field_id in this version.
# file_id	0, capabilities	1, device_settings	2, user_profile	3, hrm_profile	4, sdm_profile	5
# bike_profile	6, zones_target	7, hr_zone	8, power_zone	9, met_zone	10, sport	12, goal	15
# session	18, lap	19, record	20, event	21, device_info	23, workout	26, workout_step	27, schedule	28
# weight_scale	30, course	31, course_point	32, totals	33, activity	34, software	35, file_capabilities	37
# mesg_capabilities	38, field_capabilities	39, file_creator	49, blood_pressure	51, speed_zone	53, monitoring	55
# training_file	72, hrv	78, ant_rx	80, ant_tx	81, ant_channel_id	82, length	101, monitoring_info	103, pad	105
# slave_device	106, connectivity	127, weather_conditions	128, weather_alert	129, cadence_zone	131, hr	132, segment_lap	142
# memo_glob	145, segment_id	148, segment_leaderboard_entry	149, segment_point	150, segment_file	151, workout_session	158, watchface_settings	159
# gps_metadata	160, camera_event	161, timestamp_correlation	162, gyroscope_data	164, accelerometer_data	165, three_d_sensor_calibration	167
# video_frame	169, obdii_data	174, nmea_sentence	177, aviation_attitude	178, video	184, video_title	185, video_description	186, video_clip	187
# ohr_settings	188, exd_screen_configuration	200, exd_data_field_configuration	201, exd_data_concept_configuration	202, field_description	206
# developer_data_id	207, magnetometer_data	208, barometer_data	209, one_d_sensor_calibration	210, set	225, stress_level	227, dive_settings	258
# dive_gas	259, dive_alarm	262, exercise_title	264 dive_summary	268
      [:fields, 'c',1],
    ]
    @rec_head ={}
    @record_def ={}
    @record_definition = [
      [:field_definition_number, 'C',1],
      [:size, 'C',1], #byte
      [:base_type, 'C',1],
    ]
    parse(@header_structure,@header)
    (1..20).each do 
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
        puts "definition"
        pp rec_id.to_s(16)
        pp @record_def[rec_id]
        puts "definition end"
      else
        puts "data"
        pp @rec_head[:normal_header].to_s(16)
        pp @record_def[@rec_head[:normal_header]][:rec_size]
        yomitobashi(@record_def[@rec_head[:normal_header]][:rec_size])
      end
    end
  end
  def yomitobashi(size)
    a = @logfile.read(size)
    if(size == 43)
      b = a.unpack("VVVC20vvvvCCC")
      pp b.shift(3)
      pp b.pack("c20")
      b.shift(20)
      pp b
    end
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
