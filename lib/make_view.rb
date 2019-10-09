# -*- coding: utf-8 -*-
# enrich [lat,long] json file
# then make html by erb

require 'json'
require 'erb'

class MakeView
  def initialize(log_root)
    @log_root = log_root
    File.open(@log_root + "/data/config.json", "r") do |f|
      @config = JSON.load(f,nil, :symbolize_names => true, :create_additions => false)
    end
    @erb = ERB.new(File.read(@log_root + "/template/template.erb", :encoding => 'utf-8'), nil, '-') 
    @json_data = {}
    @html_data
  end
  def read_log(dir_name)
    if(File.exist?(@log_root + "/data/" + dir_name + "/contents.json"))
      File.open(@log_root + "/data/" + dir_name + "/contents.json", "r") do |f|
        @json_data = JSON.load(f,nil, :symbolize_names => true, :create_additions => false)
      end
    else 
      File.open(@log_root + "/data/" + dir_name + "/route.json", "r") do |f|
        @json_data[:route_data] = JSON.load(f)
        @json_data[:route_data] = @json_data[:route_data].map{|v| ((v[0] < @config[:secure_area][0][0] && v[1] > @config[:secure_area][0][1]) && (v[0] > @config[:secure_area][1][0] && v[1] < @config[:secure_area][1][1]))? nil : v}.compact
        @json_data[:start] = @json_data[:route_data][0]
        @json_data[:end] = @json_data[:route_data][-1]
      end
      File.open(@log_root + "/data/" + dir_name + "/config.json", "r") do |f|
        @json_data.merge!(JSON.load(f, nil, :symbolize_names => true, :create_additions => false))
      end
      mid_lat = (@json_data[:route_data].map{|v| v[0]}.max + @json_data[:route_data].map{|v| v[0]}.min)/2
      mid_long = (@json_data[:route_data].map{|v| v[1]}.max + @json_data[:route_data].map{|v| v[1]}.min)/2
      @json_data[:midpoint] = [mid_lat, mid_long]
      File.open(@log_root + "/data/" + dir_name + "/contents.json", "w") do |f|
        JSON.dump(@json_data,f)
      end
    end
  end
  def get_json
    return @json_data
  end
  def make_html(option=nil)
    @html_data = @erb.result(binding)
    if(option!=nil)
      File.open("tmp.html","w") do |f|
        f.puts(@html_data)
      end
    end
    true
  end
  def get_html
    return @html_data
  end
end
