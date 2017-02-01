#!/usr/bin/env ruby

require __dir__+'/../conf/secmap_conf.rb'
require __dir__+'/cassandra.rb'
require __dir__+'/redis.rb'

class Analyze

	def initialize(analyzer_name)
		@priority = [0, 1, 2, 3]
		@analyzer_name = analyzer_name
		@sleep_seconds = 5

		@redis = RedisWrapper.new
		@cassandra = CassandraWrapper.new(CASSANDRA)
	end

	def get_taskuid
		taskuid = nil
		while taskuid == nil
			@priority.each do |p|
				taskuid = @redis.get_taskuid("#{@analyzer_name}:#{p.to_s}")
				if taskuid != nil
					@redis.set_doing(@analyzer_name)
					break
				end
			end
			if taskuid == nil
				sleep(@sleep_seconds)
			end
		end
		return taskuid
	end

	def get_file(taskuid)
		res = @cassandra.get_file(taskuid)
		if res == nil
			STDERR.puts "File #{taskuid} not found!!!!"
			return nil
		else
			path = res['path'].each.first.sub(SAMPLE, '/sample/')
			path = File.expand_path(path)
			return path
		end
	end

	def analyze(file_path)
		result = ""
		max_memory = 0
		IO.popen("/analyze #{file_path}", "r+") { |f|
			while true
				begin
					memory = `ps -o rss -p #{Process::pid}`.chomp.split("\n").last.strip.to_i
					max_memory = [memory, max_memory].max
					result += f.read_nonblock(4096)
				rescue IO::WaitReadable
					sleep 1
					next
				rescue EOFError
					break
				end
			end
		}
		log = File.new('/log/memory.log', 'a')
		log.write("#{file_path}:#{max_memory}\n")
		log.close
		return result
	end

	def save_report(taskuid, report)
		@cassandra.insert_report(taskuid, report, @analyzer_name)
		@redis.del_doing(@analyzer_name)
	end

	def do
		while true
			file = nil
			taskuid = get_taskuid
			file = get_file(taskuid)
			if file == nil
				next
			end
			report = analyze(file)
			save_report(taskuid, report)
		end
	end

end
