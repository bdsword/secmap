#!/usr/bin/env ruby

require 'pathname'
require 'rubygems'
require 'find'
require 'digest/md5'
require 'digest/sha1'
require 'redis'
require __dir__+'/../conf/secmap_conf.rb'

redis = Redis.new(:host=>REDIS_ADDR, :port=>REDIS_PORT)

if( !File.exist?(LOG_HOME) )
	`mkdir -p #{LOG_HOME}`
end

if( !File.exist?(DATA_HOME) )
	`mkdir -p #{DATA_HOME}`
end

#Error Handle
def errorHandler(type)
	case type
		when "TaskUIDIsEmpty"
			sleep(5)
		else
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
