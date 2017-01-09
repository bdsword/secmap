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
		host = nil
		begin
			host = @cluster.each_host
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Cannot get hosts."
		end
		return @cluster.each_host
	end

	def init_cassandra
		begin
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
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Cannot init database."
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
		begin
			@session.execute(secmap_definition)
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Cannot create keyspace."
		end
	end

	def create_summary
		table_definition = <<-TABLE_CQL
		  CREATE TABLE #{KEYSPACE}.SUMMARY (
		    taskuid varchar PRIMARY KEY,
		    content blob
		  )
		TABLE_CQL
		begin
			@session.execute(table_definition)
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Cannot create summary table."
		end
	end

	def create_analyzer(analyzer)
		table_definition = <<-TABLE_CQL
		  CREATE TABLE #{KEYSPACE}.#{analyzer} (
		    taskuid varchar PRIMARY KEY,
		    overall varchar,
		    analyzer varchar
		  )
		TABLE_CQL
		begin
			@session.execute(table_definition)
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Cannot create analyzer table."
		end
	end

	def drop_table(table)
		table_definition = <<-TABLE_CQL
		  DROP TABLE #{KEYSPACE}.#{table} 
		TABLE_CQL
		begin
			@session.execute(table_definition)
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Cannot drop analyzer table."
		end
	end

	def list_tables
		tables = []
		begin
			@cluster.keyspace('secmap').each_table do |table|
				tables.push(table.name)
			end
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Cannot get all tables."
		end
		return tables
	end

	def insert_file(file)
		begin
			statement = @session.prepare("INSERT INTO #{KEYSPACE}.summary (taskuid, content) VALUES (?, ?)")
			taskuid = generateSecmapUID(file)
			content = File.new(file,'rb').read
			@session.execute(statement, arguments: [taskuid, content], timeout: 3)
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts file+" error!!!!!!"
			taskuid = nil
		end
		return taskuid
	end

	def get_file(taskuid)
		r = nil
		begin
			statement = @session.prepare("SELECT * FROM #{KEYSPACE}.summary WHERE taskuid = ? ")
			rows = @session.execute(statement, arguments: [taskuid], timeout: 3)
			rows.each do |row|
				r = row
				break
			end
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Get file #{taskuid} error!!!!!!"
		end
		return r
	end

	def insert_report(taskuid, report, analyzer)
		begin
			host = Socket.gethostname
			statement = @session.prepare("INSERT INTO #{KEYSPACE}.#{analyzer} (taskuid, overall, analyzer) VALUES (?, ?, ?)")
			@session.execute(statement, arguments: [taskuid, report, "#{analyzer}@#{host}"], timeout: 3)
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts report+" error!!!!!!"
		end
	end

	def get_report(taskuid, analyzer)
		r = nil
		begin
			statement = @session.prepare("SELECT * FROM #{KEYSPACE}.#{analyzer} WHERE taskuid = ?")
			rows = @session.execute(statement, arguments: [taskuid], timeout: 3)
			rows.each do |row|
				r = row
				break
			end
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Get report error!!!!!!"
		end
		return r
	end

	def get_all_report(analyzer)
		report = ""
		begin
			statement = @session.prepare("SELECT * FROM #{KEYSPACE}.#{analyzer}")
			rows = @session.execute(statement, timeout: 3)
			rows.each do |row|
				report += "#{row['taskuid']}\t#{row['overall']}\t#{row['analyzer']}\n"
			end
		rescue Exception => e
			STDERR.puts e.message
			STDERR.puts "Get all report error!!!!!!"
		end
		return report
	end

	def close
		@session.close
		@cluster.close
	end

end
