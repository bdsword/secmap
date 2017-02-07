#!/usr/bin/env ruby

require __dir__+'/lib/command.rb'
Dir[__dir__+"/service/*.rb"].each {|file| require file }
Dir[__dir__+"/client/*.rb"].each {|file| require file }

class Secmap < Command

  def initialize(commandName="dockerTemplate")
    super(commandName)

    @commandTable.append("service", -1, "service", [""])
    @commandTable.append("client", -1, "client", [""])
  end

  def callClass(rbs)
    if ARGV.length == 1
      puts "Available command : #{rbs * ' | '} ."
      exit
    end
    if rbs.include?(ARGV[1])
      type, command = ARGV.shift(2)
      Object.const_get(command).new($0+" #{type} #{command}").main
    else
      puts "Available command : #{rbs * ' | '} ."
    end
  end

  def service(*args)
    services = []
    Dir[__dir__+'/service/*.rb'].each do |s|
      services.push(File.basename(s,'.rb')[0].upcase+File.basename(s,'.rb')[1..-1])
    end
    callClass(services)
  end

  def client(*args)
    clients = []
    Dir[__dir__+'/client/*.rb'].each do |s|
      clients.push(File.basename(s,'.rb')[0].upcase+File.basename(s,'.rb')[1..-1])
    end
    callClass(clients)
  end

end

if __FILE__ == $0
  Secmap.new.main
end
