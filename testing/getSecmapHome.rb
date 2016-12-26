#!/usr/bin/ruby

require 'pathname'

path = Pathname.new(__FILE__).dirname.realpath.to_s + "/../../../../"
#path = Dir.(path.to_s).pwd
path=`cd #{path} && pwd`

puts path

