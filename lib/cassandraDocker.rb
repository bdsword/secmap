#!/usr/bin/env ruby

require 'sys/filesystem'
require 'socket'
require __dir__+'/common.rb'
require __dir__+'/docker.rb'

class CassandraDocker < DockerWrapper

	def initialize
		@dockername = "secmap-cassandra"
		@dockerimage = "cassandra:3.9"
	end

	def createContainer
		if checkContainer
			puts "container #{@dockername} already exist"
			return
		end
		tokens = (Sys::Filesystem.stat('/').block_size * Sys::Filesystem.stat('/').blocks_available / 1024.0 / 1024.0 / 1024.0 / 1024.0 * 256).to_i
		hostIP = nil
		Socket.ip_address_list.each do |ip|
			if ip.ip_address.index('192.168.') != nil
				hostIP = ip.ip_address
				break
			end
		end
		res = Docker::Container.create(
		  'Image' => @dockerimage,
		  'name' => @dockername,
		  'Volumes' => { '/var/lib/cassandra' => {} },
		  'ENV' => [
		    "CASSANDRA_CLUSTER_NAME='SECMAP Cluster'",
		    "CASSANDRA_NUM_TOKENS=#{tokens}",
		    #"CASSANDRA_SEEDS=192.168.100.1,192.168.100.3",
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
		)
		puts res
	end
end

if  __FILE__ == $0
	if ARGV.length != 1
		puts "usage: #{__FILE__} init/start/stop/status"
		exit
	end
	c = CassandraDocker.new
	case ARGV[0]
	when 'init'
		c.getImage
		c.createContainer
	when 'start'
		c.startContainer
		`echo docker > #{__dir__}../storage/cassandra.pid`
	when 'stop'
		c.stopContainer
		`rm #{__dir__}../storage/cassandra.pid`
	when 'status'
		puts "running ? " + c.infoContainer["State"]["Running"].to_s
	else
		puts "usage: #{__FILE__} init/start/stop/status"
	end
end
