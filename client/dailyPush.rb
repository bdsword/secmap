#!/usr/bin/env ruby

require __dir__+'/../conf/secmap_conf.rb'
require __dir__+'/pushTask.rb'

if __FILE__ == $0
  p = PushTask.new('')
  DAILY.each do |daily|
    Dir.glob(daily+"/**/*/").each do |d|
      sec_of_day = 60 * 60 * 24
      if (Time.now.tv_sec/sec_of_day - File.new(d).mtime.tv_sec/sec_of_day) == 1
        p.push_dir(d, 'all', 2)
      end
    end
  end
end
