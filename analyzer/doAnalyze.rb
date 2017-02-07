#!/usr/bin/env ruby

require __dir__+'/../lib/analyze.rb'

if __FILE__ == $0
  a = Analyze.new(ENV['analyzer']).do
end
