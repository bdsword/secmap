#!/usr/bin/env ruby
require 'socket'
require 'rubygems'
require 'cassandra'
require 'pathname'
load "~/secmap-run/lib/common.rb"

col_family = ARGV[0]


begin
	cassandra_ip =  CASSANDRA[rand(CASSANDRA.size)]
	client = Cassandra.new(KEYSPACE , cassandra_ip.to_s+':'+CASSANDRAPORT)
	client.disable_node_auto_discovery!
	
	keyspaces = client.send('client').describe_keyspaces
	keyspace_def = keyspaces.find{ |ks| ks.name == KEYSPACE }
	keyspace_def.cf_defs.each{ |cf| puts "#{cf.id}:#{cf.name}" }
	client.disconnect!
	
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

