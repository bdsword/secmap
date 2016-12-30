#!/usr/bin/env ruby
# invokeAnalysis( command , filename)==>bool timeout
# safe invoke analyzers by resource limit
require __dir__+'/common.rb'

command = ARGV * " "
filename = ARGV[-1]

puts "XXXX" + command

startTime = Time.new
Signal.trap("SIGXCPU") do
	`echo "[#{Time.now.to_s}] invokeAnalysis:#{filename} [TIMEOUT]" >> #{LOG_HOME}/analysis.log `
	exit 98 
end

Process.setrlimit( Process::RLIMIT_CPU , CLEAN_UP_TIME.to_i, FORCE_QUIT_TIME.to_i )
		
`#{command}`
	
if( File.exist?(filename))
	`rm #{filename}`	
end

endTime = Time.new
`echo "[#{Time.now.to_s}] #{filename} takes [#{endTime-startTime}]" >>#{LOG_HOME}/analysis.log`
