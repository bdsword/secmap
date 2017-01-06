#!/usr/bin/env ruby

require __dir__+'/../conf/secmap_conf.rb'
require __dir__+'/../lib/common.rb'
require __dir__+'/../lib/command.rb'
require __dir__+'/../lib/cassandra.rb'
require __dir__+'/../lib/redis.rb'

class PushTask < Command

	def initialize(commandName)
		super(commandName)

		@cassandra = CassandraWrapper.new(CASSANDRA)
		@redis = RedisWrapper.new
		@analyzer = @redis.get_analyzer
		if @analyzer == nil
			@analyzer = ANALYZER
		end
		@commandTable.append("addFile", 3, "push_file", ["Add file to task list.", "Usage: addFile <file path> <analyzer> <priority> .", "Analyzer can be all ."])
		@commandTable.append("addDir", 3, "push_dir", ["Add all files under directory to task list.", "Usage: addDir <dir path> <analyzer> <priority> .", "Analyzer can be all ."])
	end

	def push_file(filepath, analyzer, priority)
		taskuid = @cassandra.insert_file(filepath)
		if taskuid == nil
			STDERR.puts "Insert file fail!!!!"
			return
		end
		if analyzer == 'all'
			@analyzer.each do |a|
				@redis.push_taskuid(taskuid, a, priority)
			end
		else
			@redis.push_taskuid(taskuid, analyzer, priority)
		end
		puts "#{taskuid}\t#{File.expand_path(filepath)}"
	end

	def push_dir(dirpath, analyzer, priority)
		if dirpath[-1] == '/'
			dirpath = dirpath[0..-2]
		end
		Dir.glob("#{dirpath}/**/*", File::FNM_DOTMATCH).each do |f|
			if !File.file?(f)
				next
			end
			push_file(f, analyzer, priority)
		end
	end

end

if __FILE__ == $0
	PushTask.new($0).main
end
