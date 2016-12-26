#!/usr/bin/ruby

list = ARGV[0]
file = ARGV[1]
remotelocate = ARGV[2]

arr = list.split(/:/)
arr.each do |host|
   p host   
   `scp -r #{file} #{host}:#{remotelocate}`
end
