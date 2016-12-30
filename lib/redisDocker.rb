#!/usr/bin/env ruby

require __dir__+'/common.rb'
require __dir__+'/docker.rb'

class RedisDocker < DockerWrapper

	def initialize
		@dockername = "secmap-redis"
		@dockerimage = "redis:3.2.6"

		@createOptions = {
		  'Image' => @dockerimage,
		  'name' => @dockername,
		  'Volumes' => { '/usr/local/etc/redis/redis.conf' => {} },
		  'HostConfig' => {
		    #'Binds' => [":/usr/local/etc/redis/redis.conf"],
		    'PortBindings' => {
		      '6379/tcp' => [{ 'HostPort' => '6379' }]
		    }
		  }
		}
	end
end

if  __FILE__ == $0
	c = RedisDocker.new
	c.main(__dir__+'/../storage/redis.pid')
end
