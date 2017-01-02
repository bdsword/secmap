#!/usr/bin/env ruby

require __dir__+'/../../lib/analyzer.rb'

class Helloworld < Analyzer

	def initialize
		super
		@analyzer_name = 'helloworld'
	end

	def analyze(file_path)
		return "Hello World!\nScan #{file_path} Done!!!"
	end

end

if __FILE__ == $0
	Helloworld.new.do
end
