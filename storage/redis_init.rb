#!/usr/bin/env ruby

require 'rubygems'
require 'redis'


redis = Redis.new(:host=>ARGV[0],:port=>ARGV[1]);

# Store the IPs of cassandra nodes
# ex: redis['CASSANDRA'] = '192.168.100.1 192.168.100.2 192.168.100.3 ...'
redis['CASSANDRA'] = ''
redis['CASSANDRAPORT'] = 9160
redis['REDIS_PORT'] = 6379

# Store the IP of the redis node
# ex: redis['REDIS_ADDR'] = '192.168.100.100'
redis['REDIS_ADDR'] = ''
redis['KEYSPACE'] = 'SECMAP'
# Store the analyzers
# ex: redis['ANALYZERS'] = 'MBA CLAMAV VirusTotal FRNSR Antivir Kaspersky'
redis['ANALYZERS'] = ''
redis['CLEAN_UP_TIME'] = '420'    #7  MIN
redis['FORCE_QUIT_TIME'] = '600'  #10 MIN

#redis['cassandra'].each_line(' '){|s| p s}
redis.quit
