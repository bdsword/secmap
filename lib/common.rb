#!/usr/bin/env ruby

require 'digest/md5'
require 'digest/sha1'
require __dir__+'/../conf/secmap_conf.rb'

def createLogHome
	if( !File.exist?(LOG_HOME) )
		`mkdir -p #{LOG_HOME}`
	end
end

def createDataHome
	if( !File.exist?(DATA_HOME) )
		`mkdir -p #{DATA_HOME}`
	end
end

def generateSecmapUID( filename )
    content = File.new( filename ).read
    id = Digest::MD5.hexdigest(content)
    id <<  Digest::SHA1.hexdigest(content)
    id << File.size?(filename).to_s
    return id
end
