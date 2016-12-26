#!/usr/bin/ruby

dll=`ls | grep .dll`
exe=`ls | grep .exe`

dll.each_line do |line|
	`clamdscan #{line.strip!} >> HELLO_WORLD.log`
end

exe.each_line do |line|
        `clamdscan #{line.strip!} >> HELLO_WORLD.log`
end
