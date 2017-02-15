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
    @commandTable.append("addDirBase", 4, "push_dir_base", ["Add all files with some basename under directory to task list.", "Usage: addDir <dir path> <analyzer> <priority> <basename> .", "Analyzer can be all ."])
  end

  def push_file(filepath, analyzer, priority)
    taskuid = @cassandra.insert_file(filepath)
    if taskuid == nil
      STDERR.puts "Insert file fail!!!!"
      return
    end
    push_to_redis(taskuid, analyzer, priority)
    puts "#{taskuid}\t#{File.expand_path(filepath)}"
    return "#{taskuid}\t#{File.expand_path(filepath)}"
  end

  def push_to_redis(taskuid, analyzer, priority)
    if analyzer == 'all'
      @analyzer.each do |a|
        @redis.push_taskuid(taskuid, a, priority)
      end
    else
      @redis.push_taskuid(taskuid, analyzer, priority)
    end
  end

  def create_all_taskuid(dir)
    all_taskuid = File.new("#{dir}/all_taskuid", 'w')
    Dir.glob("#{dir}/*").each do |f|
      if !File.file?(f) or File.basename(f) == 'all_taskuid'
        next
      end
      STDOUT.reopen('/dev/null')
      taskuid = @cassandra.insert_file(f)
      if taskuid != nil
        all_taskuid.write("#{taskuid}\t#{File.expand_path(f)}\n")
      else
        all_taskuid.write("Push file #{f} error!!!!\n")
      end
      STDOUT.reopen($stdout)
    end
    all_taskuid.close
  end

  def push_dir(dirpath, analyzer, priority)
    dirpath = File.expand_path(dirpath)

    Dir.glob("#{dirpath}/**/*/").push(dirpath).each do |d|
      if !File.exist?("#{d}/all_taskuid")
        create_all_taskuid(d)
      end
      lines = File.new("#{d}/all_taskuid", 'r').readlines.each do |line|
        taskuid = line.strip.split("\t")[0]
        push_to_redis(taskuid, analyzer, priority)
      end
    end
  end

  def push_dir_base(dirpath, analyzer, priority, basename)
    dirpath = File.expand_path(dirpath)

    Dir.glob("#{dirpath}/**/*/").push(dirpath).each do |d|
      if !File.exist?("#{d}/all_taskuid")
        create_all_taskuid(d)
      end
      lines = File.new("#{d}/all_taskuid", 'r').readlines.each do |line|
        taskuid, filename = line.strip.split("\t")
        if filename.match("\.#{basename}$") != nil
          push_to_redis(taskuid, analyzer, priority)
        end
      end
    end
  end

end

if __FILE__ == $0
  PushTask.new($0).main
end
