#!/usr/bin/ruby

require 'pathname'
require 'socket'
require 'rubygems'
require 'cassandra'
require 'redis'
requirepath = Pathname.new(__FILE__).dirname.realpath+"../lib/common.rb"
load requirepath

#proper = PropertyLoader.new("../common/property.conf")
#LogPath   = proper.getPro("LOGPATH")+'analyzerInvoker.log'
#commandInfo = checkVersion
#command =  ARGV[0]
#AnalyzerHome = ARGV[1]
#Log = File.open(LogPath,'a')

ANALYZER_PATH="#{ENV['ANALYZER_HOME']}/#{ARGV[0]}"

Dir.chdir(ANALYZER_PATH)
proper = PropertyLoader.new("config")
ANALYZER_TYPE =  proper.getPro("TYPE")
ANALYZER_LOG =  proper.getPro("LOG")
ANAYSIS_COMMAND = proper.getPro("COMMAND") 

`echo #{Process.pid} > AnalyzerInvoker.pid`

loop{
		loadCommandTable()
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
		#if( result == NIL ) errorHandler() end

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
		#if( result == NIL ) errorHandler() end
}

