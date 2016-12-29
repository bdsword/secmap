#!/usr/bin/env ruby

require 'docker'

class DockerWrapper

	def initialize
		@dockername = nil
		@dockerimage = nil
	end

	def getImage
		if checkImage
			puts "#{@dockerimage} already exist"
			return
		end
		image = Docker::Image.create('fromImage' => @dockerimage)
		puts image
	end

	def checkImage
		return Docker::Image.exist?(@dockerimage)
	end

	def checkContainer
		exist = true
		begin
			Docker::Container.get(@dockername)
		rescue Docker::Error::NotFoundError
			exist = false
		end
		return exist
	end

	def createContainer
		if checkContainer
			puts "container #{@dockername} already exist"
			return
		end
		res = Docker::Container.create(
		  'Image' => @dockerimage,
		  'name' => @dockername
		)
		puts res
	end

	def startContainer
		if infoContainer["State"]["Running"]
			puts "#{@dockername} is already running."
			return
		end
		begin
			container = Docker::Container.get(@dockername)
			container.start
		rescue Docker::Error::NotFoundError
			puts "#{@dockername} container not create yet."
		end
	end

	def stopContainer
		if !infoContainer["State"]["Running"]
			puts "#{@dockername} has been stopped."
			return
		end
		begin
			container = Docker::Container.get(@dockername)
			container.kill
			container.stop
		rescue Docker::Error::NotFoundError
			puts "#{@dockername} container not create yet."
		end
	end

	def statsContainer
		stats = nil
		begin
			container = Docker::Container.get(@dockername)
			stats = container.stats
		rescue Docker::Error::NotFoundError
			puts "#{@dockername} container not create yet."
		end
		return stats
	end

	def infoContainer
		info = nil
		begin
			container = Docker::Container.get(@dockername)
			info = container.json
		rescue Docker::Error::NotFoundError
			puts "#{@dockername} container not create yet."
		end
		return info
	end
end
