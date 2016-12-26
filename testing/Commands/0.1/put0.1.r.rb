#!/usr/bin/ruby
require 'rubygems'
require 'redis'
require '../common/propertyLoader.rb'

if (ARGV.size()>=1) #need to modify
   data    = ARGV[0].split(' ')
else
   puts "[usage] ./PutToRedis.rb <data>"
   exit
end

id = ARGV[0] 
time = ARGV[1]
priority =  ARGV[2]


#puts "put **"+ id.chomp() +"** : "+time.chomp()+ " to redis"
redis =Redis.new
proper = PropertyLoader.new("../common/property.conf")
analyzers = proper.getPro("ANALYZERS").split(' ')
LogPath   = proper.getPro("LOGPATH")+'dispatcher.log'
Log = File.open(LogPath,'a')

#//use a class to take id and addr
#p analyzers
for analyzer in analyzers
   Log.puts "put   : put #{id.to_s+":"+time.to_s} to queue #{analyzer+priority.to_s}"
   #p analyzer+priority.to_s
   redis.rpush((analyzer+priority.to_s),(id.to_s+":"+time.to_s))
end

