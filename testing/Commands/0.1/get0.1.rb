#!/usr/bin/ruby

require 'socket'

if (ARGV.size()==3)
    host  = ARGV[0]
    port  = ARGV[1]
    analyzer    = ARGV[2]
else
    puts "[usage] ./GET.rb <host> <port> <analyzer name>"
    exit
end

socket = TCPSocket.open(host,port)
socket.puts "./GET.r.rb "<< analyzer
str = socket.gets
if str.chomp=='nil' then
	socket.close
	puts "nil"
	exit
end
arr=str.split(/ /)
id = arr[0]
puts id
socket.close



