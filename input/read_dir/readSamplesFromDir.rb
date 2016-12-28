#!/usr/bin/env ruby
require 'find'
require 'shellwords'
$KCODE = 'esun'

target_path = ARGV[0]
total = `find #{target_path.inspect} -depth | wc -l`.chop
if(total == 0 )
	puts "[readSampleFromDir] No Files"
	exit
end

i = 0
Find.find(target_path) do |path|
   #puts path
   if !File::directory?(path)
		escaped_path = Shellwords.escape(path)
		
		i+=1
		result = "[#{i}/#{total}]"

		if( `file #{escaped_path} | grep executable`.nil?  )
			result += "#{escaped_path} is not executables."
		elsif
			`./pushTaskFromDir.rb #{escaped_path} `
			x = $?.exitstatus
			if( x == 0 )
				result+= "[readSampleFromDir DONE] #{escaped_path} "
			elsif( x == 5 )
				result+= "[readSampleFromDir REDIS FAIL] #{escaped_path} "
			elsif( x == 4 )
				result+= "[readSampleFromDir CASSANDRA FAIL] #{escaped_path} "
			else
				result += "[readSampleFromDir ERROR] unknown error!! #{x}"
			end
		end	
		puts result
	   #sleep 1
	end
end 
