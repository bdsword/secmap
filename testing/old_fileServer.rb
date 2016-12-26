#!/usr/bin/ruby

require 'socket'
require 'rubygems'
require 'redis'
require '/opt/workspace/common/propertyLoade.rb'

proper     = PropertyLoader.new("/opt/workspace/common/property.conf")
port = proper.getPro('port');
server = TCPServer.open(1236)
redis =Redis.new

loop{
   Thread.start(server.accept) do |client|
     p "client connect"
     command = client.gets
     comtok = command.split(/ /)
     if comtok[0] == '/get'
        p 'get command'
        id = comtok[1]
        id.chop!
        p "get id :"+id+"from client"
        #p redis[id]
        client.puts(redis[id])
        client.close 
     else 
        p "unknown command"
     end
   end
}


