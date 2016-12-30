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

`echo #{Process.pid} > AnalyzerInvoker.pid`

loop{
		begin	#get TaskUID from Redis server. If TaskUID is NIL, then sleep and retry
			taskUID=`#{$commands['getTaskUID']} #{ANALYZER_TYPE} #{ARGV[0]}`.chop		
			raise 'No Task in Redis Queue' if taskUID == ""
		rescue
			sleep(5)
			retry
		end

		`#{$commands['getFileContent']} #{taskUID}`
		x = $?.exitstatus
		if( x != 0 )
			`echo "[#{Time.now.to_s}] getFileContent: #{x}" >> #{LOG_HOME}/analysis.log`	
			next
		end

		`#{$commands['invokeAnalysis']}  #{ANAYSIS_COMMAND}  #{taskUID}.*`
		x = $?.exitstatus
		if( x != 0 )
			`echo "[#{Time.now.to_s}] invokeAnalysis: #{x}" >> #{LOG_HOME}/analysis.log`
			next
		end

		`#{$commands['saveReportToCassandra']} #{ANALYZER_LOG} #{taskUID} #{ANALYZER_TYPE}`
		x = $?.exitstatus
		if( x != 0 )
			`echo "[#{Time.now.to_s}] saveReportToCassandra: #{x}" >> #{LOG_HOME}/analysis.log`
			next
		end
}
