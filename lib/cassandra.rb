#!/usr/bin/env ruby

require 'cassandra'
require 'socket'
require __dir__+'/../conf/secmap_conf.rb'
require __dir__+'/common.rb'
require __dir__+'/redis.rb'

class CassandraWrapper

	def initialize(ip)
		begin
			@cluster = Cassandra.cluster(hosts: ip)
			@session = @cluster.connect
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Cannot connect to cassandra cluster host on #{ip.to_s}."
			exit
		end

	end

	def available_host
		return @cluster.each_host
	end

	def init_cassandra
		if @cluster.keyspace(KEYSPACE) == nil
			create_secmap
			create_summary
			analyzers = RedisWrapper.new.get_analyzer
			if analyzers == nil
				analyzers = ANALYZER
			end
			analyzers.each do |analyzer|
				create_analyzer(analyzer)
			end
		end
	end

	def create_secmap
		secmap_definition = <<-KEYSPACE_CQL
		  CREATE KEYSPACE #{KEYSPACE}
		  WITH replication = {
		    'class': 'SimpleStrategy',
		    'replication_factor': 3
		  }
		KEYSPACE_CQL
		@session.execute(secmap_definition)
	end

	def create_summary
		table_definition = <<-TABLE_CQL
		  CREATE TABLE #{KEYSPACE}.SUMMARY (
		      taskuid varchar PRIMARY KEY,
		      content blob
		  )
		TABLE_CQL
		@session.execute(table_definition)
	end

	def create_analyzer(analyzer)
		table_definition = <<-TABLE_CQL
		  CREATE TABLE #{KEYSPACE}.#{analyzer} (
		    taskuid varchar PRIMARY KEY,
		    overall varchar,
		    analyzer varchar
		  )
		TABLE_CQL
		@session.execute(table_definition)
	end

	def drop_table(table)
		table_definition = <<-TABLE_CQL
                  DROP TABLE #{KEYSPACE}.#{table} 
                TABLE_CQL
		@session.execute(table_definition)
	end

	def list_tables
		tables = []
		@cluster.keyspace('secmap').each_table do |table|
			tables.push(table.name)
		end
		return tables
	end

	def insert_file(file)
		statement = @session.prepare("INSERT INTO #{KEYSPACE}.summary (taskuid, content) VALUES (?, ?)")
		taskuid = generateSecmapUID(file)
		content = File.new(file,'rb').read
		begin
			@session.execute(statement, arguments: [taskuid, content], timeout: 20)
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts file+" error!!!!!!"
			taskuid = nil
		end
		return taskuid
	end

	def get_file(taskuid)
		statement = @session.prepare("SELECT * FROM #{KEYSPACE}.summary WHERE taskuid = ? ")
		rows = @session.execute(statement, arguments: [taskuid], timeout: 20)
		rows.each do |row|
			return row
		end
		return nil
	end

	def insert_report(taskuid, report, analyzer)
		host = Socket.gethostname
		statement = @session.prepare("INSERT INTO #{KEYSPACE}.#{analyzer} (taskuid, overall, analyzer) VALUES (?, ?, ?)")
		begin
			@session.execute(statement, arguments: [taskuid, report, "#{analyzer}@#{host}"], timeout: 20)
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts report+" error!!!!!!"
		end
	end

	def get_report(taskuid, analyzer)
		statement = @session.prepare("SELECT * FROM #{KEYSPACE}.#{analyzer} WHERE taskuid = ?")
		rows = @session.execute(statement, arguments: [taskuid], timeout: 20)
		rows.each do |row|
			return row
		end
		return nil
	end

	def get_all_report(analyzer)
		statement = @session.prepare("SELECT * FROM #{KEYSPACE}.#{analyzer}")
		rows = @session.execute(statement, timeout: 20)
		report = ""
		rows.each do |row|
			report += "#{row['taskuid']}\t#{row['overall']}\t#{row['analyzer']}\n"
		end
		return report
	end

	def close
		@session.close
		@cluster.close
	end

end
