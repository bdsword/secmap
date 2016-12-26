#!/usr/bin/ruby

require 'pathname'
repath = Pathname.new(__FILE__).dirname.realpath+"./common.rb"
load repath


pat = ARGV[0..-1]
#out = `cat ../logs/analysis.log|grep "#{pat}"|grep DONE|awk '{split($0,a,":");print a[4]}'`
out = `cat ../logs/taskUID_vs_filename.log|grep "home/dsns/disk1s1/hello/"|awk '{print $1}'`
i = 0
file = File.new("MBAreport","w")
loadCommandTable()
out.each{|s|
	l = s.chomp
	i = i+1
#	pz l.chomp
#	p $commands['getReportFromCassandra']
	y = `#{$commands['getReportFromCassandra']} #{l} MBA`

	file.write(y)
	file.write("\n")
	x = `#{$commands['getReportFromCassandra']} #{l} CLAMAV`

#	`#{$commands['getFileContent']} #{l}`
	`echo "#{x}" >> ./CLAMAVreport`
#	`echo "\\\\\\\\\\\\\\\\\\\\\\\\" >> ./report.txt`
#	p x
#	i++
}

puts "total: #{i}"

