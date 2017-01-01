#!/usr/bin/env ruby

require 'socket'
require __dir__+'/../../conf/secmap_conf.rb'
require LIB_HOME+'/docker.rb'

class ClamavDocker < DockerWrapper

	def initialize(commandName, prefix="")
		super(commandName, prefix, "secmap-clamav", "secmap:clamav", __dir__)

		@createOptions = {
		  'Image' => @dockerImage,
		  'name' => @dockerName,
		  'Hostname' => Socket.gethostname,
		  'Volumes' => { '/home/dsns/secmap' => {} },
		  'HostConfig' => {
		    'Binds' => ["/home/dsns/secmap:/home/dsns/secmap"],
		  }
		}
	end

end

if  __FILE__ == $0
	ClamavDocker.new($0).main
end
