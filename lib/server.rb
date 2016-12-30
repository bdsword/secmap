#!/usr/bin/env ruby
# encoding: utf-8

require 'time'
require 'socket'               # Get sockets from stdlib
require 'openssl'
require 'thread'
require 'pathname'
require 'rubygems'
require 'redis'
repath = Pathname.new(__FILE__).dirname.realpath+"../../lib/common.rb"
load repath


#------------------certification setting----------------
store = OpenSSL::X509::Store.new
#store.add_cert(OpenSSL::X509::Certificate.new(File.open("mjib.crt")))
#store.add_cert(OpenSSL::X509::Certificate.new(File.open("cli.crt")))
#store.add_cert(OpenSSL::X509::Certificate.new(File.open("new_mjib.crt")))
store.add_cert(OpenSSL::X509::Certificate.new(File.open("ca.crt")))
store.purpose = OpenSSL::X509::PURPOSE_SSL_CLIENT

sslContext = OpenSSL::SSL::SSLContext.new
sslContext.cert_store = store
sslContext.cert = OpenSSL::X509::Certificate.new(File.open("ca.crt"))
sslContext.key = OpenSSL::PKey::RSA.new(File.open("ca.key"))

flags = OpenSSL::SSL::VERIFY_PEER|OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
sslContext.verify_mode = flags
Socket.do_not_reverse_lookup = true

#--------------------------------------------------------

def saveFILE client, filename
	begin
  		file = File.new("/tmp/qwe/"+File.basename(filename),"w")
  		puts "/tmp/qwe/"+File.basename(filename)
		length=client.gets
		if(length.nil?)
			exit
		else
			length.chomp!
		end	
		puts "size "+length+" byte"
		chunk = 1024
		bufferSize = (length.to_i>chunk)?chunk : length.to_i
		i=0
  		while line=client.read(bufferSize) do
    		i+=line.length
			file.write(line)
			bufferSize = ((length.to_i-i)>chunk)?chunk : (length.to_i-i)
			if(i>=length.to_i)
				break
			end	
		end

		puts File.basename(filename)+" ok\n" 
  		file.close
			
		long_filename = "/tmp/qwe/"+File.basename(filename)

		`./PushTask.rb #{long_filename}`
		client.puts(generateSecmapUID(long_filename));

		client.close
		puts "================finish======================="

		exit
        rescue 
			client.close
			file.close
			p $!
			#sleep 
			exit
		end	

end

def getREPO taskid
	 repo=""
	 clam = `#{$commands['getReportFromCassandra']} #{taskid} CLAMAV `
	 cas = `#{$commands['getReportFromCassandra']} #{taskid} MBA`
	 forenser = `#{$commands['getReportFromCassandra']} #{taskid} FRNSR`
	 #puts clam
	 #puts cas
	 #puts forenser
	 # hsucw for debug 2013/11/21
	 #if clam =~ /No CLAMAV Report for #{taskid}/ and cas =~/No MBA Report for #{taskid}/ and clam.size ==1 and cas.size ==1 and forenser=~ /No FRNSR Report for #{taskid}/
	 	# do nothing
	 #else
	 if clam =~/No CLAMAV Report for #{taskid}/
	 	#do nothing
	 else
		clam = `#{$commands['getReportFromCassandra']} #{taskid} CLAMAV |grep #{taskid} |awk -F":" '{print $2}'`
	 end
	 	repo += "CLAMAV:"
		repo +=  clam
		repo += "\n"
	 	repo += "MALWARE ANALYSIS (NCTU-dsns):\n"
	 	repo += cas
		repo += "\n"
		repo += "ShellCode ANALYSIS (NCTU-forenser):\n"
		repo += forenser 
		#end
     #puts "myreport"
	 #puts repo
	 return repo
end

def transmitBF client, mapaddr
	file = File.new(mapaddr,"r+")
	puts mapaddr
	length = file.stat.size
	chunk = 1024
        bufferSize = (length>1024)?chunk : length
        i=0 
        while line=file.read(bufferSize) do
	        i+=line.length
                client.write(line)
                bufferSize = ((length.to_i-i)>chunk)?chunk : (length.to_i-i)
                if(i>=length.to_i)
               		break
                end 
        end 
	client.flush
end
def clearREPO filename
	`touch /tmp/#{filename}`
	`#{$commands['saveReportToCassandra']} "/tmp/#{filename}" #{filename} MBA`
	`#{$commands['saveReportToCassandra']} "/tmp/#{filename}" #{filename} CLAMAV`
	`rm /tmp/#{filename}`
	return "done"
end

`mkdir -p /tmp/qwe/`
`echo #{Process.pid} > server.pid`
server = TCPServer.open(10009)  # Socket to listen on port 10009

sslServer = OpenSSL::SSL::SSLServer.new(server, sslContext)  #----ssl server start

loadCommandTable()
filequeue = Queue.new
reportqueue =Queue.new
loop { 

	 # Servers run forever
	#
#   if(queue.size>100)
#	  sleep 3
#	  next
#  end
  begin 
  	client = sslServer.accept       # Wait for a client to connection
	#client = server.accept
	puts 'client connection '
  rescue
	next	
  end 
  Thread.new {
	while (getline = client.gets.chomp)
		if(getline.nil?)
           Thread.exit
		end
		
		filename = getline[5..-1]
		puts "#{Time.now}:#{getline}"
		case getline[0..3]
		when "FILE"
				filequeue << filename
				puts "file Queue Size: "+filequeue.size.to_s
				fork{
					#clearREPO filename #delete old report from cassandra
					saveFILE client, filename #save file into cassandra
					clearREPO filename
				}
				Process.wait
				filequeue.pop
			when "REPO"
				reportqueue << filename
				puts "report Queue Size: "+reportqueue.size.to_s
				fork {
					repo =  getREPO filename
					#getREPO filename
					client.puts(repo)
					#puts repo
					client.flush
				}
				Process.wait
				reportqueue.pop
			when "CLRE"  #clear report
				result = clearREPO filename
				client.puts(result)
				client.flush
			when "CKBF"  #return bf time
				mapaddr = "../../bloomfilter/output/white.tar"
				time = `ls -al #{mapaddr}|grep "white.tar" |awk '{print $6}'`
				client.puts(time)
				client.flush
				puts time
			when "UPBF"
				puts "transmit start"
				mapaddr = "../../bloomfilter/output/white.tar"
				fork{
					transmitBF client, mapaddr
				}
				puts "transmit done"
			else
				
				client.puts("error command")
				client.flush
				puts "#{time} with error command #{getline[0..3]}"
				client.close
				Thread.exit

		end  #end case
	end #end while
	client.close
  }
  #client_tmp.close                 # Disconnect from the client
}



