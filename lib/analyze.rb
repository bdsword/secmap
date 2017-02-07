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
    @log = File.new("/log/#{@analyzer_name}.log", 'a')
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
      return res['path'].each.first
    end
  end

  def analyze(file_path)
    result = ""
    max_memory = 0
    max_cpu = 0.0
    last_cputime = 0
    last_etimes = 0
    IO.popen("/analyze #{file_path}", "r+") { |f|
      while true
        begin
          memory, cputime, etimes = `ps -o vsz,cputime,etimes -p #{f.pid}`.chomp.split("\n").last.split(' ')
          memory = memory.strip.to_i
          etimes = etimes.strip.to_i
          h,m,s = cputime.split(':')
          cputime = h.strip.to_i*60*60 + m.strip.to_i*60 + s.strip.to_i
          cpu = (cputime - last_cputime) / (etimes - last_etimes).to_f
          if cpu > 1
            puts "#{cputime} #{last_cputime} #{etimes} #{last_etimes}\n"
          end
          last_cputime = cputime
          last_etimes = etimes
          if cpu.nan?
            cpu = 0.0
          end
          max_memory = [memory, max_memory].max
          max_cpu = [cpu, max_cpu].max
          while true
            result += f.read_nonblock(1024*1024*1024)
          end
        rescue IO::WaitReadable
          sleep 1
          next
        rescue EOFError
          break
        end
      end
    }
    begin
      report = JSON.parse(result)
    rescue JSON::ParserError
      report = {'stat' => 'error', 'messagetype' => 'string', 'message' => 'Analyzer error'}
    end
    if report['stat'] == 'error'
      @log.write("#{file_path}:#{max_memory}:#{max_cpu*100}:#{last_etimes}:#{report['message']}\n")
    else
      @log.write("#{file_path}:#{max_memory}:#{max_cpu*100}:#{last_etimes}:success\n")
    end
    return result
  end

  def save_report(taskuid, report)
    if @cassandra.insert_report(taskuid, report, @analyzer_name) == false
      @log.write("ERROR: Report > 16MB.\n")
    end
    @redis.del_doing(@analyzer_name)
  end

  def do
    while true
      t1 = Time.now
      file = nil
      taskuid = get_taskuid
      file = get_file(taskuid)
      if file == nil
        next
      end
      report = analyze(file)
      t2 = Time.now
      save_report(taskuid, report)
      t3 = Time.now
      @log.write("#{t2-t1} #{t3-t2} #{t3-t1}\n")
      @log.flush
    end
  end

end
