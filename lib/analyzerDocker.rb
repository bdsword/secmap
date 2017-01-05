#!/usr/bin/env ruby

require 'socket'
require __dir__+'/../conf/secmap_conf.rb'
require __dir__+'/docker.rb'

class AnalyzerDocker < DockerWrapper

	def initialize(dockerImage)
		@dockerImage = "#{DOCKER}:#{dockerImage}"
		@analyzerName = dockerImage
		super('', '', @dockerImage, __dir__)
		@dockerName = " "

		@createOptions = {
		  'Image' => @dockerImage,
		  'Hostname' => Socket.gethostname,
		  'AttachStdin': true,
		  'AttachStdout': true,
		  'AttachStderr': true,
		  'Tty': true,
		  'Entrypoint' => "/secmap/analyzer/doAnalyze.rb",
		  'Volumes' => { '/secmap' => {} },
		  'Labels' => { 'secmap' => @analyzerName },
		  'ENV' => ["analyzer=#{@analyzerName}"],
		  'HostConfig' => {
		    'Binds' => ["#{File.expand_path(__dir__+"/../")}:/secmap:ro"],
		  }
		}
		puts @createOptions
	end

	def startAnalyze
		pullImage
		createContainer
		startContainer
		#exec(["/secmap/analyzer/doAnalyze.rb"], detach: true)
	end

	def stopAnalyze
		stopContainer
	end

end
