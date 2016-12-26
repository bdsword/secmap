#!/usr/bin/ruby
require 'socket'
require '../common/propertyLoader.rb'
require 'rubygems'
require 'cassandra/0.7'

#require 'XMLparser.rb'

#send /get command to Dispatcher and get fileid in form:
#<id | time>
#and store in hash item
def getfile(host,port,analyzer)
    socket = TCPSocket.open(host,port)
    socket.puts "get0.1 "+analyzer
    str = socket.gets
	#p str
    if str.chomp=='nil' then
       socket.close
    #   p "noo file to get"
       return nil
    #p 'test'
	end
    arr=str.split(/ /)
	p str 
    id = arr[3]
    time = arr[4]
    #p 'get id '+id+'with timestamp ' 
    if id.chomp=='nil' then
       socket.close
       #p "noo file to get"
       return nil
    #p 'test' 
	end
    #time = arr[1]

    item = {'id'=>id,'time'=>time}
    #p item
    socket.close
    return item
end 

#load property
proper = PropertyLoader.new("../common/property.conf")
host =proper.getPro('DISPATCHERADDR');
port = proper.getPro('PORT');
CassandraHost = proper.getPro('CASSANDRA')
CassandraPort = proper.getPro('CASSANDRAPORT')
Keyspace = proper.getPro('KEYSPACE')
#Analyzer = proper.getPro('ANALYZERS')
LogPath   = proper.getPro("LOGPATH")+'analyzerInvoker.log'
Log      =  File.open(LogPath,'a')
SecmapHome = proper.getPro('SECMAPHOME')
AnalyzerHome = proper.getPro('ANALYZERHOME')
Analyzer   = proper.getPro('ANALYZERS')

#load analyzer config
AnalyzerDir = ARGV[0]
AnalyzerPATH = AnalyzerHome+'/'+AnalyzerDir;
AnalyProper = PropertyLoader.new(AnalyzerPATH+"/config")
command     = AnalyProper.getPro('COMMAND') + " tmpfile.exe"
resultLog   = AnalyProper.getPro('LOG')
#command form : need to be excute command
#command  = proper.getPro('COMMAND') + " tmpfile.exe"
Log.puts "*** excute get0.1_new ***"

item = getfile(host,port,Analyzer)
if item.nil? then
#    p "sleep 3"
    Log.puts "get	:no file to get , sleep 3 second to get"
    sleep 3
    exit
end  
   #p "stage two=== get from cassandra and encode"
Log.puts "get	: connect to Cassandra host #{CassandraHost+':'+CassandraPort}"
Log.puts "get	: Keyspace #{Keyspace}, Column Family :SUMMARY"
client = Cassandra.new(Keyspace,CassandraHost+':'+CassandraPort)
#   p 'id' + item['id']
   #client.keyspaces
value = client.get(:SUMMARY,item['id'])
   #calculate time used
time   = Time.new.to_i - item['time'].to_i
   #write into tmp file for analysis
file   = File.new("#{AnalyzerPATH}/tmpfile.exe",'w')
file.write(value['content'])
file.flush
   #%x{#{command}}: execute command
   #XMLparse parse return report to key-value format
   #result = XMLparse %x{#{command}}
#   p command
p `cd #{AnalyzerPATH} ;#{command}`
p "********************************* print *********************************"
result = `cd #{AnalyzerPATH} ;cat #{resultLog}` 
p result
Log.puts "get   :cd #{AnalyzerPATH} ;#{command}"
#   p result
   #puts 'now time:'+ Time.new.to_s
   #puts 'total time: '+time.to_s
   #insert result to cassandra
client.insert(:SUMMARY,item['id'],{"Overall"=>result}) # column family cap
   #log.syswrite(item['id']+"\n")
Log.puts "get	: "+item['id'].to_s
Log.puts "get    : "+result.to_s
Log.puts "get    : "+'now time:'+ Time.new.to_s+"\t"+'total time: '+time.to_s
