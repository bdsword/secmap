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

target_path = ARGV[0]
Find.find(target_path) do |path|
   if !File::directory?(path)
		escaped_path = Shellwords.escape(path)	
		
		uid = generateSecmapUID(path)
		report= File.basename(path)
		report+= "\n"
		report+= "UNIQUE ID: #{uid}\n"
		
		ftype = `file #{escaped_path} |  awk -F":" '{print $2}'`
		if( $?.to_i == 0)
			report+= "FILE TYPE: #{ftype}"
		else
			report+= "\t\t\`file #{escaped_path}\` ERROR:#{$?.to_i}"
		end

		fsize = `ls -alh #{escaped_path} | awk '{print $5}'`
		if( $?.to_i == 0 )
			report+= "FILE SIZE: #{fsize}"
		else
			report+= "\t\t\`ls -alh #{escaped_path}\` ERROR:#{$?.to_i}"
		end

		report+= "CLAMAV:\n"
		clamav_report= `./getReportFromCassandra.rb #{uid} CLAMAV | grep #{uid} | awk -F":" '{print $2}'`
		if( $?.to_i == 0 )	
			if( clamav_report == "nil" )
				report+= "[NIL CLAMAV] ClamAV not finished or miss #{id}"
			else
				report+= clamav_report
			end
		else
			report+= "\t\t\`getReportFromCassandra.rb #{uid} CLAMAV\` ERROR:#{$?.to_i}"
		end

		report+= "MALWARE ANALYSIS (NCTU-dsns):\n"
		mba_result =  `../../lib/getReportFromCassandra.rb #{uid} MBA_Rootkit`	
		if( $?.to_i == 0 )
			if( mba_result == "nil" )
				report+= "[NIL MBA] Malware Behavior Analysis not finished or miss #{id}"
			elsif(   mba_result.index("Packet tainted").to_i - mba_result.index("Process tainted").to_i !=  "===== Process tainted =====\n".length )
				report+= mba_result
			else
				report+= "[FAIL] no report for Malware Behavior Analysis #{uid} \n"
				report+= mba_result
			end
		else
			report+= "\t\t\`getReportFromCassandra.rb #{uid} MBA_Rootkit\` ERROR:#{$?.to_i}"
		end

		report+= "\n\n"
		puts report
   end
end 



