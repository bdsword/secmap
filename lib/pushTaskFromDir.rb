#!/usr/bin/env ruby
require 'shellwords'
require 'pathname'
requirepath = Pathname.new(__FILE__).dirname.realpath+"../../lib/common.rb"
load requirepath

path =  ARGV[0]
escaped_path = Shellwords.escape(path)	
loadCommandTable()
taskUID = generateSecmapUID( path )
	
	`#{$commands['putToCassandra']} #{taskUID} #{escaped_path}`
	x = $?.exitstatus
	if( x != 0 )
		puts "[pushTaskFromDir FAIL] cannot to push file content into Cassandra."
		exit 4
   end
	`#{$commands['putToRedis']} 2 #{taskUID}`
	x = $?.exitstatus
   if( x != 0 )
      puts "[pushTaskFromDir FAIL] cannot to push file content into Redis."
		exit 5
   end
	
	#puts "[pushTaskFromDir DONE] #{taskUID}"

	#if( result.index("[putToCassandra FAIL]") == nil )
	#	result = `#{$commands['putToRedis']} 2 #{taskUID}`
	#	puts "[pushTaskFromDir DONE] #{taskUID}"	
	#else
	#	puts "[pushTaskFromDir FAIL] cannot to push file content into Cassandra."
	#end
