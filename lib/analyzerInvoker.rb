#!/usr/bin/env ruby

require 'pathname'
require 'socket'
require 'rubygems'
require __dir__+'/redisCli.rb'
require __dir__+'/cql.rb'

ANALYZER_PATH="#{ENV['ANALYZER_HOME']}/#{ARGV[0]}"

Dir.chdir(ANALYZER_PATH)
proper = PropertyLoader.new("config")
ANALYZER_TYPE =  proper.getPro("TYPE")
ANALYZER_LOG =  proper.getPro("LOG")
ANAYSIS_COMMAND = proper.getPro("COMMAND") 
ANALYZER_IDENTIFY = "#{ANALYZER_PATH}@#{HOST_ADDR}"

`echo #{Process.pid} > AnalyzerInvoker.pid`

redis = RedisCli.new.get
loop{
	redis.sadd("analyzers", ANALYZER_IDENTIFY)
	begin	#get TaskUID from Redis server. If TaskUID is NIL, then sleep and retry
		taskuid = nil
		(0..3).each do |p|
			if redis.llen("#{ANALYZER_TYPE}:#{p.to_s}") > 0
				taskuid = redis.lpop("#{ANALYZER_TYPE}:#{p.to_s}")
				break
			end
		end
		raise 'No Task in Redis Queue' if taskuid == nil
		redis.setex(ANALYZER_IDENTIFY, "no job")
	rescue
		redis.setex(ANALYZER_IDENTIFY, taskuid)
		sleep(5)
		retry
	end

	cql = Cql.new(:ip => CASSANDRA)
	row = cql.get_file(taskuid)
	cql.close
	if row != nil
		if row['content'] != nil
			File.new(row['taskuid'], 'wb').write(row['content'])
		else
			`echo "[#{Time.now.to_s}] invokeAnalysis: row not exist" >> #{LOG_HOME}/analysis.log`
			next
		end
	else
		`echo "[#{Time.now.to_s}] invokeAnalysis: file is nil" >> #{LOG_HOME}/analysis.log`
		next
	end

	`#{LIB_HOME}/invokeAnalysis.rb #{ANAYSIS_COMMAND} #{taskUID}`
	x = $?.exitstatus
	if( x != 0 )
		`echo "[#{Time.now.to_s}] invokeAnalysis: #{x}" >> #{LOG_HOME}/analysis.log`
		next
	end

	report = File.new(ANALYZER_LOG).read
	cql = Cql.new(:ip => CASSANDRA)
	cql.insert_report(taskuid, report, ANALYZER_TYPE, ANALYZER_IDENTIFY)
	cql.close
}
