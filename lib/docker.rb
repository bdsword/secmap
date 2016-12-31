#!/usr/bin/env ruby

require 'docker'
require __dir__+'/command.rb'

class DockerWrapper < Command

	def initialize(commandName="dockerTemplate", prfix="", dockerName, dockerImage)
		super(commandName, prfix)
		@dockerName = dockerName
		@dockerImage = dockerImage
		@createOptions = {'Image' => @dockerImage, 'name' => @dockerName}

		@commandTable.append("get", 0, "getImage", ["Get #{@dockerImage}."])
		@commandTable.append("create", 0, "createContainer", ["Create #{@dockerName} container from #{@dockerImage}."])
		@commandTable.append("start", 0, "startContainer", ["Start #{@dockerName}."])
		@commandTable.append("stop", 0, "stopContainer", ["Stop #{@dockerName}."])
		@commandTable.append("restart", 0, "restartContainer", ["Retart #{@dockerName}."])
		@commandTable.append("status", 0, "status", ["Show #{@dockerName} status."])
	end

	def getImage
		if checkImage
			puts "#{@dockerImage} already exist"
			return
		end
		image = Docker::Image.create('fromImage' => @dockerImage)
		puts image
	end

	def checkImage
		return Docker::Image.exist?(@dockerImage)
	end

	def checkContainer
		exist = true
		begin
			Docker::Container.get(@dockerName)
		rescue Docker::Error::NotFoundError
			exist = false
		end
		return exist
	end

	def createContainer
		if checkContainer
			puts "container #{@dockerName} already exist"
			return
		end
		res = Docker::Container.create(@createOptions)
		puts res
	end

	def startContainer
		if infoContainer["State"]["Running"]
			puts "#{@dockerName} is already running."
			return
		end
		begin
			container = Docker::Container.get(@dockerName)
			container.start
		rescue Docker::Error::NotFoundError
			puts "#{@dockerName} container not create yet."
		end
	end

	def stopContainer
		if !infoContainer["State"]["Running"]
			puts "#{@dockerName} has been stopped."
			return
		end
		begin
			container = Docker::Container.get(@dockerName)
			container.kill
			container.stop
		rescue Docker::Error::NotFoundError
			puts "#{@dockerName} container not create yet."
		end
	end

	def restartContainer
		stopContainer
		startContainer
	end

	def status
		puts "Running ? #{infoContainer["State"]["Running"].to_s}"
	end

	def statsContainer
		stats = nil
		begin
			container = Docker::Container.get(@dockerName)
			stats = container.stats
		rescue Docker::Error::NotFoundError
			puts "#{@dockerName} container not create yet."
		end
		return stats
	end

	def infoContainer
		info = nil
		begin
			container = Docker::Container.get(@dockerName)
			info = container.json
		rescue Docker::Error::NotFoundError
			puts "#{@dockerName} container not create yet."
		end
		return info
	end

end
