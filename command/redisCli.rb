#!/usr/bin/env ruby

require 'redis'
require __dir__+'/../conf/secmap_conf.rb'
require LIB_HOME+'/command.rb'

class RedisCli < Command

	def initialize(commandName, prefix)
		super(commandName, prefix)

		begin
			@r = Redis.new(:host => REDIS_ADDR, :port => REDIS_PORT)
		rescue
			puts "redis server #{REDIS_ADDR} is not available."
		end

		@commandTable.append("init", 0, "initRedis", ["Initialize redis data."])
		@commandTable.append("status", 0, "status", ["Show redis status."])
	end

	def initRedis
		@r.flushdb
		REDIS_INIT.each do |key, value|
			@r[key] = value
		end
	end

	def status
		available = true
		begin
			@r.ping
		rescue
			available = false
		end
		return available
	end

	def get
		return @r
	end

end

if __FILE__ == $0
	r = RedisCli.new($0, "")
	r.main
end
