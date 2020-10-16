#!/usr/bin/env ruby

require 'webrick'
require 'cgi'

$algo = '123'

$session = {}
#server = WEBrick::HTTPServer.new(:Port => 6666, :MimeTypes => {"rhtml" => "text/html"}, :DocumentRoot => 'www')
server = WEBrick::HTTPServer.new(:Port => 6666, :MimeTypes => {"rhtml" => "text/html"})
server.mount("/", WEBrick::HTTPServlet::FileHandler, 'www')


#server = WEBrick::HTTPServer.new(:Port => 6666, :DocumentRoot => 'www')

['INT', 'TERM'].each { |s| trap(s) { server.shutdown } }

server.start
