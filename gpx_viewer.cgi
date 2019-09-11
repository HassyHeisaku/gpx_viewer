#!/usr/local/bin/ruby

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)) + '/lib')
require 'make_view'
require 'cgi'

cgi = CGI.new
mv = MakeView.new(File.expand_path(File.dirname(__FILE__)))
route = cgi["route"]
mv.read_log(route)
mv.make_html
cgi.out({"type" => "text/html", "charset" => "utf-8"}){mv.get_html}

