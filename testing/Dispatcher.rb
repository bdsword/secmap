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

def getVersion
      tuple = {}
	  Dir.entries('../Commands').sort.each do |substr|  
		  if substr=='.' || substr=='..' then next end
		  Dir.entries('../Commands/'+substr).each do |com|  
			if com=='.' || com=='..' then next end 
			version = substr    
			command = com.sub(/\d+.\d+/,"")     
			command = command.sub(/.rb/,"")
			item ={'version'=>version.to_f , 'path'=>"../Commands/#{substr}/#{com}"}         
			#item ={'version'=>0.2 , 'path'=>"../Commands/#{substr}    /#{com}"}
			tuple[command]=item       
		  end
	  end  
	  p tuple 
	  return tuple;  
end	

def getComVer(command)
     index = (command =~ /\d+.\d/)
     version = command[index-command.length,command.length-index]
     return version.to_f
end

def getCommand msg
	p 'msgparse : '+ msg 
    str=msg.sub(/\d+.\d+/,"")   
    str=str.sub(/.rb/,"")
	return str+'.r'
end	

def printVersionInfo commandInfo
   str=''
   commandInfo.each_key do |key|
     str+="#{key}\t version:#{commandInfo[key]['version']}\t path:#{commandInfo[key]['path']}\n"
   end
  return str
end

proper = PropertyLoader.new("../common/property.conf")
port = proper.getPro("PORT") 
analyzers = proper.getPro("ANALYZERS").split(' ')
LogPath   = proper.getPro("LOGPATH")+'dispatcher.log'
commandInfo = getVersion

Log = File.open(LogPath,'a')     
Log.puts "Dispatcher	:Starting up at "+Time.new.inspect
Log.puts "starting config **********************************************"
Log.puts "Dispatcher    :bind port #{port}"
Log.puts "Dispatcher	:all analyzer"
Log.puts analyzers
Log.puts printVersionInfo(commandInfo)
Log.puts "**************************************************************"
Log.flush

#-------log pid file-------------
pid = Process.pid
`echo #{pid} > dispatcher.pid`
#-------------------------------

p analyzers
server = TCPServer.open(port)
loop{
   Thread.start(server.accept) do |client| #concurrency hadle each client
      Log.puts "Dispatcher    :client connect from "
      msg = client.gets
      comtok = msg.split(/ /)
      commandVer = getComVer comtok[0]
      command = getCommand comtok[0]
      binfile = commandInfo[command]['path']
      Log.puts "Dispatcher    :receive command "
      Log.flush
      #p binfile
      if commandInfo[command]['version']<commandVer &&  !File.exists?(binfile) then
         #parameter = msg.sub(comtok[0],"")a
         Log.puts "Dispatcher	:detect new version...update"
         Log.puts "Dispatcher	:excute ruby ../common/update.rb  #{commandVer} #{comtok[0]}.r.rb"
	 update = `ruby ../common/update.rb  #{commandVer} #{comtok[0]}.r.rb`
         Log.puts "Dispatcher	: "+update
         Log.puts "Dispatcher	: update finish , reconstruct commandInfo"
         commandInfo = getVersion
         Log.puts printVersionInfo(commandInfo) 
         Log.flush
         #puts `ruby update.rb  #{commandVer} #{comtok[0]}.r.rb`
      end
      msg.sub!(comtok[0],binfile)
      resp = comtok[0] 
      if commandInfo[command]['version']>commandVer then
         resp += " oldversion #{commandInfo[command]['version']} "
      else
         resp += " newestversion #{commandInfo[command]['version']} "
      end
      resp += `#{msg}`
      Log.puts "Dispatcher   : "+resp
      Log.flush  
      client.puts resp 
      client.close
   end
}
