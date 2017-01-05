#!/usr/bin/env ruby

require __dir__+'/../../lib/analyzer.rb'

class Clamav < Analyzer

	def initialize
		super
		@analyzer_name = 'clamav'
	end

	def analyze(file_path)
		return `clamdscan #{file_path}`
	end

end

if __FILE__ == $0
	Clamav.new.do
end
