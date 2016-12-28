#!/usr/bin/env ruby

require 'pathname'
require 'socket'
require 'rubygems'
require 'cassandra/0.7'
requirepath = Pathname.new(__FILE__).dirname.realpath+"../lib/common.rb"
load requirepath

#require 'conf/secmap_conf.rb'
#puts "getFileContent"


i = 0
ret = 0
while( ARGV.length > i )

	taskUid = ARGV[i]
	outFileName = taskUid	

	begin
		cassandra_ip =  CASSANDRA[rand(CASSANDRA.size)]
		client = Cassandra.new(KEYSPACE , cassandra_ip.to_s+':'+CASSANDRAPORT)
		client.disable_node_auto_discovery!
		value = client.get(:SUMMARY, taskUid )
		client.disconnect!

	rescue => detail
		puts "cannot connect to IP #{cassandra_ip}"
		CASSANDRA.delete(cassandra_ip)
		if( CASSANDRA.size > 0)
			retry
		else
			puts "cassandra error"
			if( value == "")
    			`echo "[#{Time.now.to_s}] getFileContent:#{outFileName} cassandra error" >> #{LOG_HOME}/analysis.log`
			end
				print detail.backtrace.join("\n")
			exit 4
		end   
	end

	i+= 1
	if( value.nil? )
		puts "NO SUMMARY information for #{taskUid}"
		ret = 3
		next
	elsif( value['content'].nil? )
		puts "NO file content for #{taskUid}"
		ret = 4
		next
	elsif( value['content'].size > 0 )
		file = File.new( outFileName , "w")
		file.write(value['content'])
		file.flush
		file.close
	
		retString = `file #{outFileName}`
		if (retString =~ /(DLL)/)
			newFileName = outFileName+".dll"
		else
			newFileName = outFileName+".exe"
		end
		`mv #{outFileName} #{newFileName}`
	else
		puts "Empty file content:#{outFileName}"
	end
end
exit ret
