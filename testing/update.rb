#!/usr/bin/ruby

CommandServer = 'pc10'

def getVersion(command)
   index = (command =~ /\d+.\d/)
   version = command[index-command.length,command.length-index]
   return version
end

def close_version filename,version
    Dir.entries('../Commands/').sort.reverse.each do |substr|
        if substr == '.' || substr == '..' then
	         next
		end
    	respfilename=filename.sub(version,substr)
	    if File.exists?('../Commands/'+substr+'/'+respfilename) then
			 puts  "get "+'../Commands/'+substr+'/'+respfilename
	         return substr
		end
    end
    return nil
end

def update version,filename
    old_ver = close_version(filename,version)
    cc= 'echo "get '+version +'/'+filename+'"| tftp pc10'
    str = `#{cc}`
    p str
	if File.zero?(filename)
        `rm #{filename}`
		p 'no such file in server'
		return
	end	
    if old_ver.nil? then
        p 'no such file , update directly'
        `mv #{filename} ../Commands/#{version}/#{filename}`
	else
	    p 'file in old version '+old_ver
	    old_name = filename.sub(version,old_ver)
	    diff = `diff #{filename} ../Commands/#{old_ver}/#{old_name}`
	    if diff.empty? then
	         p 'file compatible'
	         `mv #{filename} ../Commands/#{version}/#{filename}`
        else
             p 'file not compatible , need update'
        end
    end
end

p ARGV[0]+" "+ARGV[1]
update ARGV[0],ARGV[1] 



