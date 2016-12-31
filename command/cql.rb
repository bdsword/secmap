#!/usr/bin/env ruby

require 'cassandra'
require 'socket'
require __dir__+'/../conf/secmap_conf.rb'
require LIB_HOME+'/command.rb'
require LIB_HOME+'/common.rb'

class Cql < Command
	def initialize(ip, commandName, prefix)
		super(commandName)

		begin
			@cluster = Cassandra.cluster(host: ip)
			@session = @cluster.connect
		rescue Cassandra::Errors::NoHostsAvailable
			puts "Cannot connect to cassandra cluster host on #{ip.to_s}."
			exit
		end

		if @cluster.keyspace('secmap') != nil
			@session.execute('USE secmap')
		end

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

	def available_host
		return @cluster.each_host
	end

	def init_cassandra
		if @cluster.keyspace('secmap') == nil
			create_secmap
			@session.execute('USE secmap')
			create_summary
			ANALYZER.each do |analyzer|
				create_analyzer(analyzer)
			end
		end
	end

	def create_secmap
		puts "create keyspace secmap...."
		secmap_definition = <<-KEYSPACE_CQL
		  CREATE KEYSPACE secmap
		  WITH replication = {
		    'class': 'SimpleStrategy',
		    'replication_factor': 3
		  }
		KEYSPACE_CQL
		@session.execute(secmap_definition)
	end


	def create_summary
		puts "create table summary...."
		table_definition = <<-TABLE_CQL
		  CREATE TABLE SUMMARY (
		      taskuid varchar PRIMARY KEY,
		      content blob
		  )
		TABLE_CQL
		@session.execute(table_definition)
	end

	def create_analyzer(analyzer)
		puts "create table #{analyzer}...."
		table_definition = <<-TABLE_CQL
		  CREATE TABLE #{analyzer} (
		    taskuid varchar PRIMARY KEY,
		    overall varchar,
		    analyzer varchar
		  )
		TABLE_CQL
		@session.execute(table_definition)
	end

	def drop_table(table)
		puts "drop table #{table}...."
		table_definition = <<-TABLE_CQL
                  DROP TABLE #{table} 
                TABLE_CQL
		@session.execute(table_definition)
	end

	def list_tables
		@cluster.keyspace('secmap').each_table do |table|
			puts table.name
		end
	end

	def insert_file(file)
		statement = @session.prepare('INSERT INTO summary (taskuid, content) VALUES (?, ?)')
		taskuid = generateSecmapUID(file)
		content = File.new(file,'rb').read
		@session.execute(statement, arguments: [taskuid, content])
	end

	def get_file(taskuid)
		statement = @session.prepare("SELECT * FROM summary WHERE taskuid = ? ")
		rows = @session.execute(statement, arguments: [taskuid])
		result = nil
		rows.each do |row|
			puts row['taskuid']
			puts row['content']
			result = row
		end
		return result
	end

	def insert_report(taskuid, file, analyzer)
		report = File.new(file, 'r').read
		host = Socket.gethostname
		statement = @session.prepare("INSERT INTO #{analyzer} (taskuid, overall, analyzer) VALUES (?, ?, ?)")
		@session.execute(statement, arguments: [taskuid, report, "#{ANALYZER_HOME}/#{analyzer}@#{host}"])
	end

	def get_report(taskuid, analyzer)
		statement = @session.prepare("SELECT * FROM #{analyzer} WHERE taskuid = ?")
		rows = @session.execute(statement, arguments: [taskuid])
		result = nil
		rows.each do |row|
			puts row['taskuid']
			puts row['overall']
			puts row['analyzer']
			result = row
		end
		return result
	end

	def close
		@session.close
		@cluster.close
	end

end

if  __FILE__ == $0
	c = Cql.new(CASSANDRA, $0, "")
	c.main
	c.close
end
