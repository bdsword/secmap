#!/usr/bin/env ruby

require 'pathname'
require 'rubygems'
require 'find'
require 'digest/md5'
require 'digest/sha1'
require 'redis'
secconfpath = Pathname.new(__FILE__).dirname.realpath + "../conf/secmap_conf.rb"
require secconfpath

LIB_HOME="#{ENV['SECMAP_HOME']}/lib"
LOG_HOME="#{ENV['SECMAP_HOME']}/logs"

#REDIS_PORT      	= 6379
#REDIS_ADDR 			= "192.168.100.109"
#KEYSPACE       	= "SECMAP"
#CASSANDRA      	= ["192.168.100.101", "192.168.100.102", "192.168.100.103", "192.168.100.104"]
#CASSANDRA      	= ["192.168.100.101"]
#ANALYZERS      	= ["MBA", "CLAMAV"]
#CASSANDRAPORT  	= "9160"
#CLEAN_UP_TIME     = 420 # 7 mins for clean up time
#FORCE_QUIT_TIME   = 600 # 10 mins force kill analyzer
redis = Redis.new(:host=>"127.0.0.1",:port=>6379)
begin
REDIS_PORT          = redis['REDIS_PORT']
REDIS_ADDR          = redis['REDIS_ADDR']
KEYSPACE        = redis['KEYSPACE']
CASSANDRA       = []
redis['CASSANDRA'].split(/ /).map{ |s|  CASSANDRA << s}
ANALYZERS       = []
redis['ANALYZERS'].split(/ /).map{ |s| ANALYZERS << s}
CASSANDRAPORT   = redis['CASSANDRAPORT']
CLEAN_UP_TIME     = redis['CLEAN_UP_TIME'] # 7 mins for clean up time
FORCE_QUIT_TIME   = redis['FORCE_QUIT_TIME'] # 10 mins force kill analyzes
redis.quit
rescue
	if (ARGV.index("redis") || ARGV.index("-r"))
		#do nothing
	else
		puts "redis is off now!!Please start it first."
		exit 1
	end

end

if( !File.exist?(LOG_HOME) )
	`mkdir -p #{LOG_HOME}`
end


$commands = {
}

#Error Handle
def errorHandler(type)
	case type
		when "TaskUIDIsEmpty"
			sleep(5)
		else
	end
end


# $commands HashTable for [putTo|getFrom][Cassandra|Redis]
def updateCommandTable()
#We should add checkVersion() later
end

#def loadRedisValue()
#	redis = Redis.new(:host=>"192.168.100.109",:port=>6379)
#	REDIS_PORT          = redis['REDIS_PORT']
#	REDIS_ADDR          = redis['REDIS_ADDR']
#	KEYSPACE        = redis['KEYSPACE']
#	CASSANDRA       = []
#	redis['CASSANDRA'].split(/ /).map{ |s|  CASSANDRA << s}
#	ANALYZERS       = []
#	redis['ANALYZERS'].split(/ /).map{ |s| ANALYZERS << s}
#	CASSANDRAPORT   = redis['CASSANDRAPORT']
#	CLEAN_UP_TIME     = redis['CLEAN_UP_TIME'] # 7 mins for clean up time
#	FORCE_QUIT_TIME   = redis['FORCE_QUIT_TIME'] # 10 mins force kill analyzes
#end

# Find all *.rb from ENV['SECMAP_HOME']/lib and add to $commands
def loadCommandTable()
	updateCommandTable()
	rbList = `ls #{LIB_HOME} | grep .rb `.split(/\n/)
	rbList.each do | command |
		$commands[command[0..-4]] = "#{LIB_HOME}/#{command[0..-1]}"
	end
end

def generateSecmapUID( filename )
    content = File.new( filename ).read
    id = Digest::MD5.hexdigest(content)
    #puts id
    id <<  Digest::SHA1.hexdigest(content)
    #puts File.size?(filename).to_s
    id << File.size?(filename).to_s
    return id

end



#property loader for linux-like config
class PropertyLoader
   def initialize(filename)
     @filename = filename
     @properties = {}
     load_properties()
   end

   def load_properties()
	File.open(@filename, 'r') do |properties_file|
    	properties_file.read.each_line do |line|
        line.strip!
        if (line[0] != ?# and line[0] != ?=)
          i = line.index('=')
          if (i)
            @properties[line[0..i - 1].strip] = line[i + 1..-1].strip
          else
            @properties[line] = ''
          end
        end
      end
    end
    #@properties.each {|k,v| puts "#{k}=#{v}"}
   end

   def getPro(proname)
       return @properties[proname]
   end

   def appendValue(pattern,value)
   	File.open(@filename, "r+") do |properties_file|
	   out = ""
      	   properties_file.read.each_line do |line|
	      out << line.gsub(/#{pattern}.*/){line.strip + " " + value}
           end
	   properties_file.pos = 0
    	   properties_file.print out
	   properties_file.truncate(properties_file.pos)
        end
   end

end
