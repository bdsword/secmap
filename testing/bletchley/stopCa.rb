#!/usr/bin/ruby

cassandraHost = ['xpc1','xpc2','xpc3','xpc4']

cassandraHost.each do |host|
   puts "set up host #{host}"
   msg =`ssh #{host} 'cd ~/secmap-run/secmap-0.1;./secmap.rb stop cassandra'`
   puts msg 
end

