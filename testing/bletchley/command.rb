#!/usr/bin/ruby

Hosts= ['xpc2','xpc3','xpc4','xpc5','xpc6','xpc7']
#Hosts= ['xpc1','xpc2']

Hosts.each do |host|
   puts "set up host #{host}"
   msg =`ssh #{host} 'cd ~/mba-taint-1/;mv test.sh startMBA.sh'`
   puts msg 
end

