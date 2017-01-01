#!/usr/bin/env ruby

require __dir__+'/../lib/docker.rb'

class RedisDocker < DockerWrapper

	def initialize(commandName, prefix="")
		super(commandName, prefix, "secmap-redis", "redis:3.2.6")

		@createOptions = {
		  'Image' => @dockerImage,
		  'name' => @dockerName,
		  #'Volumes' => { '/usr/local/etc/redis/' => {} },
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
	c = RedisDocker.new($0)
	c.main
end
