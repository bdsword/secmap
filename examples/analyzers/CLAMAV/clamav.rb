#!/usr/bin/ruby

dll=`ls | grep .dll`
exe=`ls | grep .exe`

dll.each_line do |line|
	`clamdscan #{line.strip!} >> CLAMAV.log`
end

exe.each_line do |line|
        `clamdscan #{line.strip!} >> CLAMAV.log`
end
