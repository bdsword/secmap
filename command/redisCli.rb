#!/usr/bin/env ruby

require 'redis'
require __dir__+'/../conf/secmap_conf.rb'

class RedisCli
	def initialize
		begin
			@r = Redis.new(:host => REDIS_ADDR, :port => REDIS_PORT)
		rescue
			puts "redis server #{REDIS_ADDR} is not available."
		end
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

	def main
		errMsg = "usage: #{__FILE__} init | status"
		if ARGV.length != 1
			puts errMsg
		end
		case ARGV[0]
		when 'init'
			puts 'initializing...'
			initRedis
		when 'status'
			puts 'running ? ' + status.to_s
		end
	end
end

if __FILE__ == $0
	r = RedisCli.new
	r.main
end
