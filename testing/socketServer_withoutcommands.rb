#!/usr/bin/ruby

require 'socket'
require 'rubygems'
require 'redis'
require '../common/propertyLoader.rb' 


#put id to redis for each analyzer's queue
#there are queu for each analyzer and priority
#each item in format: <id:time>  
def putToRedis(analyzers,priority,id,time)
  puts "put **"+ id.chomp() +"** : "+time.chomp()+ " to redis"
  redis =Redis.new
  #//use a class to take id and addr
  #p analyzers
  for analyzer in analyzers
     p analyzer
     p  (analyzer+priority.to_s)
     redis.rpush((analyzer+priority.to_s),(id+":"+time))
  end
end

#get file is from redis
#and change item into array
#array[0] : id
#array[1] : time
def getFromRedis(analyzer)
  redis =Redis.new
  str=nil
  p 'get file '+analyzer
  (0..2).each do |x|
     str = redis.lpop(analyzer+(x).to_s)
     if !str.nil? then
        p 'get file from '+analyzer+(x).to_s
        array = str.split(/:/)
        return array   
     end
  end
  if str.nil? then
      return nil
  end
  #p str
  array = str.split(/:/)
  #p array[0]
  #p array[1] 
  return array
end

proper = PropertyLoader.new("../common/property.conf")
port = proper.getPro('PORT');
analyzers = proper.getPro("ANALYZERS").split(' ')

p analyzers
server = TCPServer.open(port)
loop{
   Thread.start(server.accept) do |client| #concurrency hadle each client
      command = client.gets
      comtok = command.split(' ') 
      #puts 'connect from '+ client.peeraddr[3] +" : \n"+command
      if comtok[0] == "/put" then    #command in form /put \n fileid time priority
         id = comtok[1]
         time = comtok[2] 
	 priority = comtok[3]
	 putToRedis(analyzers,priority,id,time) 
      elsif comtok[0].chomp  == "/get" then   #command /get , send back id \n time
         arr = getFromRedis(comtok[1]) #arr => ( file id , file locate addr)
         if arr.nil? then     #if no file , send string 'nil' back
            puts 'no file to send'
            client.puts 'nil' 
         else
            puts "return "+arr[0].to_s.chomp() + " : " + arr[1].to_s.chomp()  
            client.puts arr[0]+" "+arr[1]
         end 
      else 
         p "unknown message : "+command  
      end
    
      client.close
      #puts "connection close" 
   end
}
