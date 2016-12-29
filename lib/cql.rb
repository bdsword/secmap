#!/usr/bin/env ruby

require 'cassandra'
require __dir__+'/common.rb'

class Cql
	def initialize(ip=['127.0.0.1'])
		@cluster = Cassandra.cluster(host: ip)
		@session = @cluster.connect
		if @cluster.keyspace('secmap') != nil
			@session.execute('USE secmap')
		end
	end

	def available_host
		return @cluster.each_host
	end

	def init_cassandra
		if @cluster.keyspace('secmap') == nil
			create_secmap
			@session.execute('USE secmap')
			create_summary
			ANALYZERS.each do |analyzer|
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

	def insert_file(taskuid, filepath)
		statement = @session.prepare('INSERT INTO summary (taskuid, content) VALUES (?, ?)')
		content = File.new(filepath,'rb').read
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

	def insert_report(taskuid, overall, analyzer, analyzer_holder)
		statement = @session.prepare("INSERT INTO #{analyzer} (taskuid, overall, analyzer) VALUES (?, ?, ?)")
		@session.execute(statement, arguments: [taskuid, overall, analyzer_holder])
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

	def main
		errMsg = "usage: #{__FILE__} init | createSecmap | addSummary | addTable <table name> | dropTable <table name>"\
			" | getTable | addFile <taskuid> <absolute filepath> | getFile <taskuid> | addReport <taskuid> <absolute report file path> <analyzer> <host>"\
			" | getReport <taskuid> <analyzer>"
		if ARGV.length < 1
			puts errMsg
			exit
		end
		case ARGV[0]
		when 'init'
			init_cassandra
		when 'createSecmap'
			create_secmap
		when 'addSummary'
			create_summary
		when 'addTable'
			if ARGV.length != 2
				puts errMsg
				exit
			end
			create_analyzer(ARGV[1])
		when 'dropTable'
			if ARGV.length != 2
				puts errMsg
				exit
			end
			drop_table(ARGV[1])
		when 'getTable'
			list_tables
		when 'addFile'
			if ARGV.length != 3
				puts errMsg
				exit
			end
			insert_file(ARGV[1], ARGV[2])
		when 'getFile'
			if ARGV.length != 2
				puts errMsg
				exit
			end
			get_file(ARGV[1])
		when 'addReport'
			if ARGV.length != 5
				puts errMsg
				exit
			end
			report = File.new(ARGV[2]).read
			insert_report(ARGV[1], report, ARGV[3], ARGV[4])
		when 'getReport'
			if ARGV.length != 3
				puts errMsg
				exit
			end
			get_report(ARGV[1], ARGV[2])
		else
			puts errMsg
			exit
		end
	end
end

if  __FILE__ == $0
	c = Cql.new
	c.main
	c.close
end
