#!/usr/bin/env ruby

class Command

	class CommandTable
		def initialize
			@commandHash = {}
		end

		def append(commandName, argNum, funcName, commandHelp)
			@commandHash[commandName] = {
				"argNum" => argNum,
				"funcName" => funcName,
				"help" => commandHelp
			}
		end

		def hasCommand?(command)
			return @commandHash.include?(command)
		end

		def get(command)
			return @commandHash[command]
		end

		def del(command)
			return @commandHash.delete(command)
		end

		def list
			return @commandHash.keys
		end
	end

	def initialize(commandName="commandTemplate")
		@commandTable = CommandTable.new
		@commandName = commandName

		@commandTable.append("help", 0, "help", ["Show this help message."])
		@commandTable.append("list", 0, "listCommand", ["Show every command of #{@commandName}."])
	end

	def parser(args)
		if args.length == 0
			puts "Please give command."
			puts "Type list to show commands."
			exit
		end
		if !@commandTable.hasCommand?(args[0])
			puts "Wrong command."
			puts "Type list to show commands."
			exit
		end
		c = @commandTable.get(args[0])
		if c['argNum'] != -1 && args.length != (c['argNum'] + 1)
			puts "wrong usage"
			puts "usage of #{args[0]}:"
			helpCommand(args[0])
			exit
		end
		send(c['funcName'], *args.drop(1))
	end

	def helpCommand(command, indent='')
		c = @commandTable.get(command)
		puts "#{indent}#{command} :"
		c['help'].each do |helpMessage|
			puts "#{indent}\t#{helpMessage}"
		end
	end

	def help
		puts "Usage of #{@commandName} :"
		@commandTable.list.each do |command|
			helpCommand(command, "\t")
		end
	end

	def listCommand
		puts "Commands of #{@commandName} : "
		puts "\t#{@commandTable.list * " | "}"
	end

	def main
		parser(ARGV)
	end

end
