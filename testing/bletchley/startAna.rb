#!/usr/bin/ruby

analyzerHost = ['xpc2','xpc3','xpc4']
analyzerHost.each do |host|
   #Thread.new(){
      puts "set up host #{host}"
      `ssh #{host} 'cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-1;cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-2;'`
      #msg =`ssh #{host} 'cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-2&'`
      
   #}
end

