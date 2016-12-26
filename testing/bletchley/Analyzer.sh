#!/usr/bin/bash

ssh xpc2 'cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-1;cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-2;'&

ssh xpc3 'cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-1;cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-2;'&

ssh xpc4 'cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-1;cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-2;'&

ssh xpc5 'cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-1;cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-2;~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-3'& 

ssh xpc6 'cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-1;cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-2;~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-3'&

ssh xpc7 'cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-1;cd ~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-2;~/secmap-run/secmap-0.1;./secmap.rb start mba-taint-3'&
