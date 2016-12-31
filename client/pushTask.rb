#!/usr/bin/env ruby

require __dir__+'/../conf/secmap_conf.rb'
require LIB_HOME+'/common.rb'
require LIB_HOME+'/command.rb'
require LIB_HOME+'/cassandra.rb'
require LIB_HOME+'/redis.rb'

class PushTask < Command

	def initialize
		super("pushTask", "")

		@cassandra = CassandraWrapper.new(CASSANDRA)
		@redis = RedisWrapper.new
		@commandTable.append("addFile", 3, "push_file", ["Add file to task list.", "Usage: addFile <file path> <analyzer> <priority> .", "Analyzer can be all ."])
		@commandTable.append("addDir", 3, "push_dir", ["Add all files under directory to task list.", "Usage: addDir <dir path> <analyzer> <priority> .", "Analyzer can be all ."])
	end

	def push_file(filepath, analyzer, priority)
		taskuid = @cassandra.insert_file(filepath)
		if analyzer == 'all'
			ANALYZER.each do |a|
				@redis.push_taskuid(taskuid, a, priority)
			end
		else
			@redis.push_taskuid(taskuid, analyzer, priority)
		end
	end

	def push_dir(dirpath, analyzer, priority)
		if dirpath[-1] == '/'
			dirpath = dirpath[0..-2]
		end
		Dir["#{dirpath}/**/*"].each do |f|
			if !File.file?(f)
				next
			end
			push_file(f, analyzer, priority)
		end
	end

end

if __FILE__ == $0
	PushTask.new.main
end
