#!/usr/bin/env ruby

require 'pathname'
requirepath = Pathname.new(__FILE__).dirname.realpath+"../../lib/common.rb"
load requirepath

FILENAME =  ARGV[0]

#loop{
	loadCommandTable()
	taskUID = generateSecmapUID( FILENAME )
	
	result = `#{$commands['putToCassandra']} #{taskUID} #{FILENAME}`	
	if ( result.index("[putToCassandra FAIL]") == nil )
		result = `#{$commands['putToRedis']} 1 #{taskUID}`
		puts taskUID 
	end
