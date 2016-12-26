#!/usr/bin/ruby
require 'socket'
require 'rubygems'
require 'cassandra/0.7'
require 'pathname'
requirepath = Pathname.new(__FILE__).dirname.realpath+"../lib/common.rb"
load requirepath

LOG = ARGV[0]
taskUID = ARGV[1]
ANALYZER_TYPE = ARGV[2]

report = `cat #{LOG}`
analyzer = Dir.pwd+"@"+`hostname`.chop

if( ANALYZER_TYPE == "CLAMAV" )
	found =`cat  #{LOG} | grep FOUND | awk '{print $2}'`
	if( found == "" )
		found = "MISSED"
	else
		found = "HIT "+found[0..-2]
	end
end


begin
	cassandra_ip =  CASSANDRA[rand(CASSANDRA.size)]
	client = Cassandra.new(KEYSPACE , cassandra_ip.to_s+':'+CASSANDRAPORT)
	client.disable_node_auto_discovery!
	client.insert(:"#{ANALYZER_TYPE}", taskUID,{"OVERALL"=>report , "ANALYZER" => analyzer })
	client.disconnect!

rescue CassandraThrift::Cassandra::Client::TransportException => detail
	file_size = `ls -alh #{LOG} | awk '{print $5}'`
    puts "[EXCEP] file size of #{LOG} is #{file_size}"

rescue => detail
	#CASSANDRA.delete(cassandra_ip)
	#if( CASSANDRA.size != 0)
	#	retry
	#else
		#puts "[cassandra exception] insert fail"
	puts detail	
	puts detail.backtrace.join
		#report = "cassandra error! IP:#{cassandra_ip}"
		#exit 200
	#end   
end
`echo "[#{Time.now.to_s}] [DONE] saveToCassandra[#{ANALYZER_TYPE}]:#{taskUID} #{found}" >> #{LOG_HOME}/analysis.log`
