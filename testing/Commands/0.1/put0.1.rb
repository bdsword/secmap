#!/usr/bin/ruby

require 'socket'
require 'md5'
require 'digest/sha1'
#include for property loader
require '../common/propertyLoader.rb'
require 'rubygems'
require 'cassandra/0.7'
require 'redis'

#encode file content to get file id
#<MD5|SHA1|size>
def encode(filename,content)
    id = MD5.hexdigest(content)
    #puts id
    id <<  Digest::SHA1.hexdigest(content)
    #puts File.size?(filename).to_s
    id << File.size?(filename).to_s
    #puts id
    return id
end

#send new id to server
#   /put file_id local_time
#
def sendToServer(host,port,id,priority,version) 
    socket = TCPSocket.open(host,port);
	#p "put#{version} " << id.to_s << " " << Time.new.to_i.to_s << " " << priority
    cog = File.open('./log.txt','a')
    cog.puts "put#{version} " << id.to_s << " " << Time.new.to_i.to_s << " " << priority 
    socket.puts "put#{version} " << id.to_s << " " << Time.new.to_i.to_s << " " << priority
    retval = socket.gets 
    socket.close 
	return retval
end

#add after 3/13
#put file content to cassandra
#put into Summary supercolumn
def putCassandra(id,content,client)
    client.insert(:SUMMARY, id , {"content" => content})
end



def checkVersion
    return 0.1     
end	
#load property from "/opt/workspace/common/property.conf"
proper     = PropertyLoader.new("../common/property.conf")
Dispatcher = proper.getPro('DISPATCHERADDR');
DispatcherPort = proper.getPro('PORT')
Keyspace   = proper.getPro('KEYSPACE')
CassandraList  = proper.getPro('CASSANDRA').split(' ')
CassandraPort       = proper.getPro('CASSANDRAPORT')
CassandraHost = CassandraList[rand(CassandraList.size)]
LogPath   = proper.getPro("LOGPATH")+'crawler.log'
Log = File.open(LogPath,'a')

Log.puts "*** put version:0.1 ***"
#p CassandraHost
#get file name form agrv
filename   = ARGV[0]
#p filename
version = checkVersion
#get priority form argv[1],fefault 2
#edit by bz
#--------------------------------
if  !ARGV[1].nil? && ARGV[1].to_i >=0 && ARGV[1].to_i <=1
        Priority = ARGV[1]
else
        Priority = "2"
end
#p Priority
#------------------------------------


#new cassandra object
Log.puts "put	: Keyspace #{Keyspace} , Cassandra #{CassandraHost+':'+CassandraPort}"
Log.puts "put	: put #{filename} to Cassandra"
client = Cassandra.new(Keyspace, CassandraHost+':'+CassandraPort)
#p client

file = File.open(filename);
content = file.read
#I think their is a bug!!!!
#how it can run
id = encode(filename,content)
#p id
#putRedis(id,content)
putCassandra(id,content,client)
Log.puts "put   : send to server"
str= sendToServer(Dispatcher,DispatcherPort,id,Priority,version)
puts str
Log.puts "put	: "+str 

#for test stage , not to delete file
#rmfile() need to implement  
