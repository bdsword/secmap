#!/usr/bin/ruby

list = ARGV[0]

arr = list.split(/:/)
loop{
  command = STDIN.gets 
  arr.each do |host|
     p host+command   
     p `ssh #{host} '#{command}'`
  end
}
