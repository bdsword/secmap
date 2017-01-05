#!/usr/bin/env ruby

require 'tempfile'
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
		content = @cassandra.get_file(taskuid)
		if content == nil
			STDERR.puts "File #{taskuid} not found!!!!"
			return nil
		end
		file = Tempfile.new(taskuid)
		file.binmode
		file.write(content['content'])
		File.chmod(0666, file.path)
		return file
	end

	def analyze(file_path)
		return `/analyze #{file_path}`
	end

	def save_report(taskuid, report)
		@cassandra.insert_report(taskuid, report, @analyzer_name)
	end

	def do
		while true
			file = nil
			taskuid = get_taskuid
			file = get_file(taskuid)
			if file == nil
				next
			end
			report = analyze(file.path)
			save_report(taskuid, report)
			if file != nil
				file.close
				file.unlink
			end
		end
	end

end
