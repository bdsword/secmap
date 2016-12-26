#!/usr/bin/ruby

require 'socket'
require 'rubygems'
require 'redis'
require '/opt/workspace/common/propertyLoader.rb' 

def putToRedis(id,time)
  puts "put **"+ id.chomp() +"** : "+time.chomp()+ " to redis"
  redis =Redis.new
  #array = Array.new(2)
  #array[0]=id
  #array[1]=peeradr
  #redis.lpush 'id' ,id
  #redis.lpush 'addr',peeradr  
  #//use a class to take id and addr
  p (id+":"+time)
  #redis.rpush 'a','b' 
  redis.rpush ('file' , (id+":"+time))
end

def getFromRedis()
  redis =Redis.new
  p "hahaha"
  str = redis.lpop('file')
  p 'hahah2'
  if str.nil? then
      return nil
  end
  p str
  array = str.split(/:/)
  p array[0]
  p array[1] 
  return array
end

proper = PropertyLoader.new("/opt/workspace/common/property.conf")
port = proper.getPro('port');

server = TCPServer.open(port)
loop{
   Thread.start(server.accept) do |client| #concurrency hadle each client
      command = client.gets
      comtok = command.split(' ') 
      puts 'connect from '+ client.peeraddr[3] +" : \n"+command
      if comtok[0] == "/put" then      #command in form /put \n fileid \n file_locate_address
         id = comtok[1]
         time = comtok[2] 
         #peeradr = client.peeraddr[3]      #get client addr 
         putToRedis(id,time) 
      elsif comtok[0].chomp  == "/get" then   #command /get , send back id \n time
         arr = getFromRedis() #arr => ( file id , file locate addr)
         if arr.nil? then     #if no file , send string 'nil' back
            client.puts 'nil' 
         else
            puts "put "+arr[0].to_s.chomp() + " : " + arr[1].to_s.chomp()  
            client.puts arr[0]+" "+arr[1]
         end 
      else 
         p "unknown message : "+command  
      end
    
      client.close
      puts "connection close" 
   end
}
