#!/usr/bin/ruby

Hosts= ['xpc1','xpc2','xpc3','xpc4','xpc5','xpc6','xpc7']
#Hosts= ['xpc1','xpc2']

Hosts.each do |host|
   puts "set up host #{host}"
   msg =`ssh #{host} 'cd ~/secmap/;git pull ; cd ~ ;rm -rg secmap-run ;mkdir secmap-run ; cp -r secmap/secmap-0.1 secmap-run ; mkdir ~/secmap-run/secmap-0.1/Logs;'`
   puts msg 
end

