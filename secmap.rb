#!/usr/bin/env ruby
$LOAD_PATH << './lib'
load 'common.rb'

#---------global var-----------------

$pidLocation = {
	"cassandra" => "#{ENV['SECMAP_HOME']}/storage/cassandra.pid", 
	"redis" => "#{ENV['SECMAP_HOME']}/storage/redis.pid" ,
	"server" => "#{ENV['SECMAP_HOME']}/input/server/server.pid"
}

$starttable = {    
	"cassandra" => "#{ENV['SECMAP_HOME']}/lib/cassandraDocker.rb start", 
	"redis" => "#{ENV['SECMAP_HOME']}/lib/redisDocker.rb start && #{ENV['SECMAP_HOME']}/lib/redisCli.rb init" ,
	"server" => "cd #{ENV['SECMAP_HOME']}/input/server &&  ./server.rb" 
}
$stoptable = {
	"cassandra" => "#{ENV['SECMAP_HOME']}/lib/cassandraDocker.rb stop",
   	"redis" => "#{ENV['SECMAP_HOME']}/lib/cassandraDocker.rb stop" ,
	"server" =>"kill -9 `cat #{ENV['SECMAP_HOME']}/input/server/server.pid` ; rm -f #{ENV['SECMAP_HOME']}/input/server/server.pid" 
}
#----------------------------------------
def addAllAnalyzers(runlist)
	Dir.foreach(ENV['ANALYZER_HOME']) { |file|
		abs_dir = "#{ENV['ANALYZER_HOME']}/#{file}"
		config = "#{ENV['ANALYZER_HOME']}/#{file}/config" 
		if( File.directory?(abs_dir) && File.exist?( config ) )
			runlist = pushToRunList( file , runlist )
		end
	}
	return runlist
end

def pushToRunList( analyzerDirName, runlist )

	puts "invoke analyzer:"+analyzerDirName+" into runlist"
	runlist.push analyzerDirName
	$starttable[analyzerDirName] =  "cd #{ENV['ANALYZER_HOME']}/#{analyzerDirName}; rm *.exe; echo $$ > analyzer.pid  ; #{ENV['SECMAP_HOME']}/analyzer/AnalyzerInvoker.rb  #{analyzerDirName}/"
	$stoptable[analyzerDirName] =  	"kill -9 `cat #{ENV['ANALYZER_HOME']}/#{analyzerDirName}/analyzer.pid` ;"+
									"kill -9 `cat #{ENV['ANALYZER_HOME']}/#{analyzerDirName}/AnalyzerInvoker.pid` ;"+
									"rm #{ENV['ANALYZER_HOME']}/#{analyzerDirName}/analyzer.pid;"+
									"rm #{ENV['ANALYZER_HOME']}/#{analyzerDirName}/AnalyzerInvoker.pid;"
	
	$pidLocation[analyzerDirName] = "#{ENV['ANALYZER_HOME']}/#{analyzerDirName}/analyzer.pid"
	$pidLocation[analyzerDirName+"_invoker"] = "#{ENV['ANALYZER_HOME']}/#{analyzerDirName}/AnalyzerInvoker.pid"
	return runlist
end


#----------function-----------------
def rolelist
	puts "[roles] cassandra redis"
	end

def getlist
	runlist=[]
   i = 1
   while i<ARGV.size() do 
	case ARGV[i]
		when "-c","-r","-s","cassandra","redis","server"
			if( ARGV[i] =="-c" || ARGV[i] =="cassandra" )
			    runlist.push "cassandra"
			elsif( ARGV[i] == "-r" || ARGV[i] =="redis" )
			    runlist.push "redis"
			elsif( ARGV[i] == "-s" || ARGV[i] =="server" )
			    runlist.push "server"
			end
		when "allA"
			puts "add all analyzers!!"
			runlist = addAllAnalyzers(runlist)
		when "-f"
			startForce = true	
		else
		    if( File.exist?( "#{ENV['ANALYZER_HOME']}/#{ARGV[i]}/config" ))
	    		runlist = pushToRunList(ARGV[i],runlist)
		    else
			puts "unknown " + ARGV[i] + "  {You should check whether " +ARGV[i]+" has \"config\" file}"
			rolelist
	 		exit
	  	    end
 		end #end case
   	i+=1
  	end
	return runlist
end

def isrun(service)
	if File::exists?( "#{$pidLocation[service]}" ) then
		pid = `cat #{$pidLocation[service]}`
		if pid == 'docker'
			return true
		end
		pid = pid[0..-2]
		query =`ps -p #{pid} | grep #{pid}`
		if( query != "" )
			puts "#{$pidLocation[service]} is exist and \n#{query}"
		else
			puts "#{$pidLocation[service]} might be dead pid:#{pid}"
			`rm -f #{$pidLocation[service]}`
		end
		return true
	end
	return false
end

def starton (runlist)
   i = 0
   while i<runlist.size() do
      puts $starttable[runlist[i]]
      pid = Process.fork
      if pid.nil? then
         # In child
         exec $starttable[runlist[i]]
      else 
         Process.detach(pid)
      end
		puts "#{runlist[i]} is now running."
      i+=1
   end
end

def stop (stoplist)
   i = 0
   while i<stoplist.size() do
      puts $stoptable[stoplist[i]]
		`#{$stoptable[stoplist[i]]}`
      i+=1
   end	
end
#---------------function end-------------------------

if (ARGV.size()<2) #need to modify
   puts "[usage] ./secmap.rb [start|stop] <role1> ... <roleN>"
   rolelist
   exit
end


if ARGV[0] == "start" then
	list = getlist()
   # ARGV.each do |arg|
   #     if( arg == "-f" )
   #         startForce = true
   #     end
   # end

	if(!isrun([ARGV[1]]) ||  defined? startForce ) then
	    starton(list)
	else
	    list
		puts "You can use ./secmap start \"-f\" to force execution."
	end

elsif ARGV[0] == "stop" then
   stop(getlist())
else
   rolelist
end


