#!/usr/bin/env ruby

dll=`ls | grep .dll`
exe=`ls | grep .exe`
`echo HELLO WORLD! > HELLO_WORLD.log`

dll.each_line do |line|
	`echo "file #{line.strip!}" >> HELLO_WORLD.log`
end

exe.each_line do |line|
        `echo "file #{line.strip!}" >> HELLO_WORLD.log`
end
