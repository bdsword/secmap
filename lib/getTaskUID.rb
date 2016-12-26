#!/usr/bin/ruby

require 'pathname'
require 'rubygems'
require 'redis'
require 'socket'
requirepath = Pathname.new(__FILE__).dirname.realpath+"../lib/common.rb"
load requirepath

ANALYZER_TYPE = ARGV[0]
ANALYZER_NAME = ARGV[1]
HOST_ADDR = Socket.gethostname
ANALYZER_IDENTIFY = "#{ANALYZER_NAME}@#{HOST_ADDR}"
redis = Redis.new(:host => REDIS_ADDR, :port => REDIS_PORT);
taskUID = ""
if( !redis.nil? )
	(0..3).each do |x|
		str = redis.lpop( ANALYZER_TYPE+":"+ x.to_s)
     		if( !str.nil? )
        		#p 'get file from '+ANALYZER_TYPE+(x).to_s
        		taskUID = str.split(/:/)
        		puts  taskUID
				`echo "[#{Time.now.to_s}] getTaskUID:#{taskUID}" >> #{LOG_HOME}/analysis.log`
				break
     		end
	end
end
redis.sadd "analyzers", ANALYZER_IDENTIFY
if(taskUID.eql?"")
	redis.setex ANALYZER_IDENTIFY, 300, "no job"
else
	redis.setex ANALYZER_IDENTIFY, 300, taskUID
end
redis.quit

