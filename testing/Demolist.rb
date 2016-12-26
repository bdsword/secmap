require 'rubygems'
require 'cassandra/0.7'
require 'find'

Find.find('./tmp') do |path|
   puts path
   puts File::directory?(path)
   if !File::directory?(path)
       str = './clientSocket.rb '+ path
       p str 
       %x{#{str}}
   end
end 
