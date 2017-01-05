#!/usr/bin/env ruby

require 'socket'
require __dir__+'/../../conf/secmap_conf.rb'
require __dir__+'/../../lib/docker.rb'

class HelloworldDocker < DockerWrapper

	def initialize(commandName)
		super(commandName, "secmap-helloworld", "secmap:helloworld", __dir__)

		@createOptions = {
		  'Image' => @dockerImage,
		  'name' => @dockerName,
		  'Hostname' => Socket.gethostname,
		  'Volumes' => { '/secmap' => {} },
		  'HostConfig' => {
		    'Binds' => ["#{File.expand_path(__dir__+"/../../")}:/secmap"],
		  }
		}
	end

end

if  __FILE__ == $0
	HelloworldDocker.new($0).main
end
