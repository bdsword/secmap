#!/usr/bin/ruby

cassandraHost = ['pc10']

cassandraHost.each do |host|
   puts "set up host #{host}"
   msg =`ssh #{host} 'cd ~/secmap-run/secmap-0.1;./secmap.rb start nutch'`
   puts msg 
end

