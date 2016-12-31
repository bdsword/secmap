#!/usr/bin/env ruby

require 'cassandra'
require 'socket'
require __dir__+'/../conf/secmap_conf.rb'
require LIB_HOME+'/common.rb'

class CassandraWrapper

	def initialize(ip)
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
		table_definition = <<-TABLE_CQL
		  CREATE TABLE SUMMARY (
		      taskuid varchar PRIMARY KEY,
		      content blob
		  )
		TABLE_CQL
		@session.execute(table_definition)
	end

	def create_analyzer(analyzer)
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
		table_definition = <<-TABLE_CQL
                  DROP TABLE #{table} 
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
		statement = @session.prepare('INSERT INTO summary (taskuid, content) VALUES (?, ?)')
		taskuid = generateSecmapUID(file)
		content = File.new(file,'rb').read
		@session.execute(statement, arguments: [taskuid, content])
		return taskuid
	end

	def get_file(taskuid)
		statement = @session.prepare("SELECT * FROM summary WHERE taskuid = ? ")
		rows = @session.execute(statement, arguments: [taskuid])
		rows.each do |row|
			return row
		end
	end

	def insert_report(taskuid, report, analyzer)
		host = Socket.gethostname
		statement = @session.prepare("INSERT INTO #{analyzer} (taskuid, overall, analyzer) VALUES (?, ?, ?)")
		@session.execute(statement, arguments: [taskuid, report, "#{ANALYZER_HOME}/#{analyzer}@#{host}"])
	end

	def get_report(taskuid, analyzer)
		statement = @session.prepare("SELECT * FROM #{analyzer} WHERE taskuid = ?")
		rows = @session.execute(statement, arguments: [taskuid])
		rows.each do |row|
			return row
		end
	end

	def close
		@session.close
		@cluster.close
	end

end
