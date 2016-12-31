#!/usr/bin/env ruby

require 'sys/filesystem'
require 'socket'
require __dir__+'/../conf/secmap_conf.rb'
require LIB_HOME+'/docker.rb'
require LIB_HOME+'/common.rb'

class CassandraDocker < DockerWrapper

	def initialize(commandName, prefix="")
		super(commandName, prefix, "secmap-cassandra", "cassandra:3.9")

		tokens = (Sys::Filesystem.stat('/').block_size * Sys::Filesystem.stat('/').blocks_available / 1024.0 / 1024.0 / 1024.0 / 1024.0 * 256).to_i
		hostIP = nil
		Socket.ip_address_list.each do |ip|
			if ip.ip_address.index('192.168.') != nil
				hostIP = ip.ip_address
				break
			end
		end

		@createOptions = {
		  'Image' => @dockerimage,
		  'name' => @dockername,
		  'Volumes' => { '/var/lib/cassandra' => {} },
		  'ENV' => [
		    "CASSANDRA_CLUSTER_NAME='SECMAP Cluster'",
		    "CASSANDRA_NUM_TOKENS=#{tokens}",
		    #"CASSANDRA_SEEDS=#{CASSANDRA * ' '}",
		    "CASSANDRA_BROADCAST_ADDRESS=#{hostIP}"
		  ],
		  'HostConfig' => {
		    'Binds' => ["#{DATA_HOME}:/var/lib/cassandra"],
		    'PortBindings' => {
		      '7000/tcp' => [{ 'HostPort' => '7000' }],
		      '7001/tcp' => [{ 'HostPort' => '7001' }],
		      '7199/tcp' => [{ 'HostPort' => '7199' }],
		      '9042/tcp' => [{ 'HostPort' => '9042' }],
		      '9160/tcp' => [{ 'HostPort' => '9160' }]
		    }
		  }
		}
		createDataHome
	end

end

if  __FILE__ == $0
	c = CassandraDocker.new($0)
	c.main
end
