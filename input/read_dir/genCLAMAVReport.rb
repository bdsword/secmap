#!/usr/bin/ruby
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

target_path = ARGV[0]
Find.find(target_path) do |path|
   if !File::directory?(path)
		escaped_path = Shellwords.escape(path)	
		
		uid = generateSecmapUID(path)
		#report= File.basename(path)

		#report+= "CLAMAV:\n"
		clamav_report= `./getReportFromCassandra.rb #{uid} CLAMAV | grep #{uid} | awk -F":" '{print $2}'`
		if( $?.to_i == 0 )	
			if( clamav_report == "nil" )
				report= "[NIL CLAMAV] ClamAV not finished or miss #{id}\n"
			else
				if( clamav_report != "")
					report=  clamav_report[0..-2] 
					report+= " #{uid}"
					puts report
				end
			end
		else
			report= "\t\t\`getReportFromCassandra.rb #{uid} CLAMAV\` ERROR:#{$?.to_i}\n"
		end
   end
end 



