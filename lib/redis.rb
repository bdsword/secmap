#!/usr/bin/env ruby

require 'redis'
require __dir__+'/../conf/secmap_conf.rb'

class RedisWrapper

	def initialize
		begin
			@r = Redis.new(:host => REDIS_ADDR, :port => REDIS_PORT)
		rescue
			puts "redis server #{REDIS_ADDR} is not available."
		end
	end

	def init_redis
		begin
			@r.flushdb
			REDIS_INIT.each do |key, value|
				@r[key] = value
			end
		rescue Redis::CannotConnectError
			puts "Cannot connect to redis server #{REDIS_ADDR}."
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

	def get_taskuid(analyzer)
		return @r.lpop(analyzer)
	end

end
