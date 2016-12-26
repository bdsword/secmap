#!/usr/bin/ruby
require 'rubygems'
require 'redis'
require '../common/propertyLoader.rb'

if (ARGV.size()==1)
     analyzer  = ARGV[0]
else
   puts "[usage] ./get.r.rb <analyzer>"
   exit
end

redis =Redis.new
str=nil
proper = PropertyLoader.new("../common/property.conf")
LogPath   = proper.getPro("LOGPATH")+'dispatcher.log'
Log = File.open(LogPath,'a')

(0..2).each do |x|
   str = redis.lpop(analyzer+(x).to_s)
   if !str.nil? then
      array = str.split(/:/)
      Log.puts "get	: "+array[0]+" "+array[1]
      puts array[0]+" "+array[1]
   end
end

if str.nil? then
   Log.puts "get     : no file to get"
   puts nil
end

