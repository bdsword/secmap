#!/usr/bin/perl -w 


if ($#ARGV == 1){
	$target_dir = $ARGV[0];
	$BF_map = $ARGV[1];
}
else{
	print "[usage] ./bfcheck <target_dir> <BF_map> \n";
	exit 1;
}	

@filenames = `ls $target_dir`;

open CONFLICT, ">>conflict.log";
$conflict =0;

print CONFLICT  "=======$target_dir=======with $BF_map========\n";
foreach $name (@filenames){
	chomp $name;	
	$result1=`./bf -c $target_dir/$name -o $BF_map`;
#	print "$result1\n";
	if ($result1 =~ "YES"){
		print CONFLICT "conflict $target_dir/$name\n";
		print "conflict $target_dir/$name\n";
		$conflict = $conflict+1;
	}
}

print "total file : $#filenames\nconflict : $conflict\n";
