#!/usr/bin/ruby

require 'socket'
require 'pathname'
require 'rubygems'
require 'cassandra'
requirepath = Pathname.new(__FILE__).dirname.realpath+"../lib/common.rb"
load requirepath

taskUID = ARGV[0]
filename = ARGV[1]

content = File.new(filename, 'rb').read
begin
	cassandra_ip =  CASSANDRA[rand(CASSANDRA.size)]
	client = Cassandra.new(KEYSPACE , cassandra_ip.to_s+':'+CASSANDRAPORT )
	client.disable_node_auto_discovery!
	client.insert(:SUMMARY, taskUID , {"content" => content})
	client.disconnect!
	`echo "[#{Time.now.to_s}] putToCassandra:#{taskUID}" >> #{LOG_HOME}/input.log`
rescue CassandraThrift::Cassandra::Client::TransportException => detail
	puts
	puts
	p detail
	puts
	print detail.backtrace.join("\n")

rescue => detail
	p detail
	puts "cannot connect to IP #{cassandra_ip}"
	CASSANDRA.delete(cassandra_ip)
	if( CASSANDRA.size > 0)
		retry
	else
		#print detail.backtrace.join("\n")
		puts "[putToCassandra FAIL]"
		`echo "[#{Time.now.to_s}] [Fail!!] putToCassandra:#{taskUID}" >> #{LOG_HOME}/input.log`
		puts "XXXXXXXXX100XXXXXXXXXXX"
		exit 95
	end
end

`echo "#{taskUID} #{filename}" >> #{LOG_HOME}/taskUID_vs_filename.log`
