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
		@taskuid = nil
		@time = nil
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
		@taskuid = nil
		begin
			@taskuid = @r.lpop(analyzer)
			@time = Time.new.to_s
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts 'Get taskuid fail!!!!'
			@taskuid = nil
		end
		return @taskuid
	end

	def set_doing(analyzer)
		begin
			@r.rpush("#{analyzer}:doing", "#{@taskuid}:#{@time}")
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts 'Set doing fail!!!!'
		end
	end

	def del_doing(analyzer)
		begin
			@r.lrem("#{analyzer}:doing" , 1, "#{@taskuid}:#{@time}")
			@taskuid = nil
			@time = nil
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts 'Set doing fail!!!!'
		end
	end

	def push_taskuid(taskuid, analyzer, priority)
		begin
			@r.rpush("#{analyzer}:#{priority}", taskuid)
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts 'Push task fail!!!!'
		end
	end

	def get_analyzer
		analyzer = nil
		begin
			analyzer = @r.get('ANALYZERS').split(' ')
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts 'Get analyzer from fail!!!!'
			STDERR.puts 'Use local config.'
		end
		return analyzer
	end

end
