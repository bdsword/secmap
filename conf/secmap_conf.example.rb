#!/usr/bin/env ruby

ENV['ANALYZER_HOME']   	= "/path/to/analyzers"
ENV['SECMAP_HOME']     	= "/path/to/secmap"

# redis init
REDIS_INIT = {
	# Store the IPs of cassandra nodes
	# ex: redis['CASSANDRA'] = '192.168.100.1 192.168.100.2 192.168.100.3 ...'
	'CASSANDRA' => '',
	'CASSANDRAPORT' => 9042,
	'REDIS_PORT' => 6379,
	# Store the IP of the redis node
	# ex: redis['REDIS_ADDR'] = '192.168.100.100'
	'REDIS_ADDR' => '',
	'KEYSPACE' => 'secmap',
	# Store the analyzers
	# ex: redis['ANALYZERS'] = 'MBA CLAMAV VirusTotal FRNSR Antivir Kaspersky'
	'ANALYZERS' => '',
	'CLEAN_UP_TIME' => '420',	#7  MIN
	'FORCE_QUIT_TIME' => '600'	#10 MIN
}
