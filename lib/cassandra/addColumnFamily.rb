#!/usr/bin/ruby
require 'socket'
require 'rubygems'
require 'cassandra'
require 'pathname'
load "~/secmap-run/lib/common.rb"

col_family = ARGV[0]

if( col_family.nil? )
	puts "ERROR: The Name of Column Family Cannot Be Empty"
	puts "Usage: ./addColumnFamily COL_FAMILY_NAME" 
	exit 100
end

begin
	cassandra_ip =  CASSANDRA[rand(CASSANDRA.size)]
	client = Cassandra.new(KEYSPACE , cassandra_ip.to_s+':'+CASSANDRAPORT)
	client.disable_node_auto_discovery!
	
	keyspaces = client.send('client').describe_keyspaces
	keyspace_def = keyspaces.find{ |ks| ks.name == KEYSPACE }
	target_cf_def = keyspace_def.cf_defs.find{ |cf| cf.name == col_family } 
	if( target_cf_def.nil? )
		last_cf_def = keyspace_def.cf_defs.last

		new_cf_def = last_cf_def
		#new_cf_def.id = last_cf_def.id + 1
		new_cf_def.name = col_family 
	else
		puts "column family: \"#{col_family}\" already exist!"
		exit 101
	end

	client.add_column_family(new_cf_def)
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

