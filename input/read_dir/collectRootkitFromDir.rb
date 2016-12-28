#!/usr/bin/env ruby
require 'find'
require 'md5'
require 'shellwords'

$KCODE = 'esun'

def generateSecmapUID( filename )
    content = File.new( filename ).read
    id = MD5.hexdigest(content)
    #puts id
    id <<  Digest::SHA1.hexdigest(content)
    #puts File.size?(filename).to_s
    id << File.size?(filename).to_s
    #puts id
    return id
end

failFile = File.open("FailLog", "w")
target_path = ARGV[0]
Find.find(target_path) do |path|
   if !File::directory?(path)
		escaped_path = Shellwords.escape(path)	
		
		uid = generateSecmapUID(path)
		filename= File.basename(path)
		mba_result =  `../../lib/getReportFromCassandra.rb #{uid} MBA_Rootkit`	
		if( $?.to_i == 0 )
			if( mba_result == "nil" )
				failFile.write(uid+":"+filename+"\n")
			elsif( mba_result.length>100 )
				puts filename+":"+uid
			end
		else
			failFile.write(uid+":"+filename+"\n")
		end
   end
end 



