#!/usr/bin/env ruby
require 'socket'
require 'rubygems'
require 'cassandra/0.7'
require 'pathname'
requirepath = Pathname.new(__FILE__).dirname.realpath+"../lib/common.rb"
load requirepath

taskUID = ARGV[0]
ANALYZER_TYPE = ARGV[1]


begin
	cassandra_ip =  CASSANDRA[rand(CASSANDRA.size)]
	client = Cassandra.new(KEYSPACE , cassandra_ip.to_s+':'+CASSANDRAPORT)
	client.disable_node_auto_discovery!
	result = client.get(:"#{ANALYZER_TYPE}", taskUID, "OVERALL" )
	client.disconnect!
	
	if( result.nil? )
		puts "No #{ANALYZER_TYPE} Report for #{taskUID} "
		exit 101
	else
		report = result
	end
	
	result = client.get(:"#{ANALYZER_TYPE}", taskUID, "ANALYZER" ) 
	if( result.nil? )
		result = "No information about ANALYZER"
	else
		#report += result
	end
	puts report

rescue => detail
	CASSANDRA.delete(cassandra_ip)
	if( CASSANDRA.size > 0)
		retry
	else
		print detail.backtrace.join("\n")
		report = "cassandra error! IP:#{cassandra_ip}"
		exit 104
	end   
end

