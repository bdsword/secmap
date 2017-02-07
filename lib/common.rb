#!/usr/bin/env ruby

require 'digest/md5'
require 'digest/sha1'
require __dir__+'/../conf/secmap_conf.rb'

def createLogHome
  if( !File.exist?(File.expand_path(__dir__+'/../log')) )
    `mkdir -p #{File.expand_path(__dir__+'/../log')}`
  end
end

def createDataHome
  if( !File.exist?(File.expand_path(__dir__+'/../storage')) )
    `mkdir -p #{File.expand_path(__dir__+'/../storage')}`
  end
end

def createReportHome(analyzer)
  if( !File.exist?(File.expand_path("#{REPORT}/#{analyzer}")) )
    `mkdir -p #{File.expand_path("#{REPORT}/#{analyzer}")}`
  end
end

def generateSecmapUID( filename )
  content = File.new(filename, 'r').read
  id = Digest::MD5.hexdigest(content)
  id <<  Digest::SHA1.hexdigest(content)
  id << File.size?(filename).to_s
  return id
end
