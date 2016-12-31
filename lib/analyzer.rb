#!/usr/bin/env ruby

require 'tempfile'
require __dir__+'/../conf/secmap_conf.rb'
require LIB_HOME+'/cassandra.rb'
require LIB_HOME+'/redis.rb'

class Analyzer

	def initialize
		@priority = [0, 1, 2, 3]
		@analyzer_name
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
			sleep(@sleep_seconds)
		end
		return taskuid
	end

	def get_file(taskuid)
		content = @cassandra.get_file(taskuid)['content']
		file = Tempfile.new(taskuid)
		file.binmode
		file.write(content)
		return file
	end

	def analyze(file_path)
		# do analyze
		# return report
	end

	def save_report(taskuid, report)
		@cassandra.insert_report(taskuid, report, @analyzer_name)
	end

	def do
		while true
			file = nil
			taskuid = get_taskuid
			file = get_file(taskuid)
			report = analyze(file.path)
			save_report(taskuid, report)
			if file != nil
				file.close
				file.unlink
			end
			end
		end
	end

end
