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
		max_cpu = 0
		last_cputime = 0
		last_etimes = 0
		IO.popen("/analyze #{file_path}", "r+") { |f|
			while true
				begin
					memory, cputime, etimes = `ps -o vsz,cputime,etimes -p #{Process::pid}`.chomp.split("\n").last.split(' ')
					memory = memory.strip.to_i
					etimes = etimes.strip.to_i
					h,m,s = cputime.split(':')
					cputime = h.strip.to_i*60*60 + m.strip.to_i*60 + s.strip.to_i
					cpu = (cputime - last_cputime) / (etimes - last_etimes).to_f
					max_memory = [memory, max_memory].max
					max_cpu = [cpu, max_cpu].max
					result += f.read_nonblock(4096)
				rescue IO::WaitReadable
					sleep 1
					next
				rescue EOFError
					break
				end
			end
		}
		log = File.new('/log/usage.log', 'a')
		log.write("#{file_path}:#{max_memory}:#{max_cpu}\n")
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
