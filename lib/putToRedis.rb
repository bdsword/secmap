#!/usr/bin/ruby

require 'pathname'
require 'rubygems'
require 'redis'
require 'cassandra/0.7'
requirepath = Pathname.new(__FILE__).dirname.realpath+"../lib/common.rb"
load requirepath

priority = ARGV[0]
redis = Redis.new(:host => REDIS_ADDR, :port => REDIS_PORT);

i=1
while( ARGV.length > i )
	taskUID = ARGV[i]
	ANALYZERS.each do |analyzerType|
		redis.rpush( (analyzerType+":"+priority) , taskUID )
		`echo "[#{Time.now.to_s}] putToRedis:#{taskUID} in Queue:#{analyzerType}:#{priority}" >> #{LOG_HOME}/input.log`
	end
	i+=1
end
redis.quit
