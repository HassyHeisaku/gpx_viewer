#!/usr/local/bin/ruby

$LOAD_PATH.push('./lib')
require 'make_view'
require 'cgi'

cgi = CGI.new
mv = MakeView.new('./data/')
route = cgi["route"]
mv.read_log(route)
mv.make_html
cgi.out({"type" => "text/html", "charset" => "utf-8"}){mv.get_html}

