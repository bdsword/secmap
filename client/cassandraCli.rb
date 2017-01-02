#!/usr/bin/env ruby

require 'cassandra'
require 'socket'
require __dir__+'/../conf/secmap_conf.rb'
require __dir__+'/../lib/command.rb'
require __dir__+'/../lib/common.rb'
require __dir__+'/../lib/cassandra.rb'

class CassandraCli < Command
	def initialize(ip, commandName, prefix)
		super(commandName)

		@ip = ip

		@commandTable.append("init", 0, "init_cassandra", ["Initialize cassandra keyspace and table."])
		@commandTable.append("createSecmap", 0, "create_secmap", ["Create keyspace secmap."])
		@commandTable.append("addSummary", 0, "create_summary", ["Create table secmap.summary."])
		@commandTable.append("addTable", 1, "create_analyzer", ["Create table of analyzer.", "Usage: addTable <table name>"])
		@commandTable.append("dropTable", 1, "drop_table", ["Drop table.", "Usage: dropTable <table name>"])
		@commandTable.append("getTable", 0, "list_tables", ["Show all tables."])
		@commandTable.append("addFile", 1, "insert_file", ["Insert a file to secmap.summary.", "Usage: addFile <file path>"])
		@commandTable.append("getFile", 1, "get_file", ["Get file content from cassandra by taskuid.", "Usage: getFile <taskuid>"])
		@commandTable.append("addReport", 3, "insert_report", ["Insert a report to analyzer table.", "Usage: addReport <taskuid> <report file path> <analyzer>"])
		@commandTable.append("getReport", 2, "get_report", ["Get a report by taskuid and the name of analyzer.", "Usage: getReport <taskuid> <analyzer>"])
	end

	def init_cassandra
		puts "Initialize cassandra...."
		puts "Create keyspace secmap...."
		puts "Create table summary...."
		puts "Create table all analyzers...."
		c = CassandraWrapper.new(@ip)
		c.init_cassandra
		c.close
	end

	def create_secmap
		puts "Create keyspace secmap...."
		c = CassandraWrapper.new(@ip)
		c.create_secmap
		c.close
	end

	def create_summary
		puts "Create table summary...."
		c = CassandraWrapper.new(@ip)
		c.create_summary
		c.close
	end

	def create_analyzer(analyzer)
		puts "Create table #{analyzer}...."
		c = CassandraWrapper.new(@ip)
		c.create_analyzer(analyzer)
		c.close
	end

	def drop_table(table)
		puts "drop table #{table}...."
		c = CassandraWrapper.new(@ip)
		c.drop_table(table)
		c.close
	end

	def list_tables
		c = CassandraWrapper.new(@ip)
		c.list_tables.each do |table|
			puts table
		end
		c.close
	end

	def insert_file(file)
		c = CassandraWrapper.new(@ip)
		c.insert_file(file)
		c.close
	end

	def get_file(taskuid)
		c = CassandraWrapper.new(@ip)
		result = c.get_file(taskuid)
		puts result['content']
		c.close
	end

	def insert_report(taskuid, file, analyzer)
		report = File.new(file, 'r').read
		c = CassandraWrapper.new(@ip)
		c.insert_report(taskuid, report, analyzer)
		c.close
	end

	def get_report(taskuid, analyzer)
		c = CassandraWrapper.new(@ip)
		report = c.get_report(taskuid, analyzer)
		puts report['overall']
		c.close
	end

end

if  __FILE__ == $0
	c = CassandraCli.new(CASSANDRA, $0, "")
	c.main
end
