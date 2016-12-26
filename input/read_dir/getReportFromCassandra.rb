#!/usr/bin/ruby
require 'socket'
require 'rubygems'
require 'cassandra'
require 'pathname'
requirepath = Pathname.new(__FILE__).dirname.realpath+"../../lib/common.rb"
load requirepath

taskUID = ARGV[0]
ANALYZER_TYPE = ARGV[1]

cassandra_ip =  CASSANDRA[rand(CASSANDRA.size)]
client = Cassandra.new(KEYSPACE , cassandra_ip.to_s+':'+CASSANDRAPORT)
client.disable_node_auto_discovery!


begin
	report = client.get(:"#{ANALYZER_TYPE}", taskUID, "OVERALL" )
rescue => detail
	CASSANDRA.delete(cassandra_ip)
	if( CASSANDRA.size != 0)
		cassandra_ip =  CASSANDRA[rand(CASSANDRA.size)]
		client = Cassandra.new(KEYSPACE , cassandra_ip.to_s+':'+CASSANDRAPORT)
		client.disable_node_auto_discovery!
		report = client.get(:"#{ANALYZER_TYPE}", taskUID, "OVERALL" )
	else
		print detail.backtrace.join("\n")
		report = "cassandra error! IP:#{cassandra_ip}"
	end   
end
puts report

