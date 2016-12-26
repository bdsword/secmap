#!/bin/sh





echo "dsns@192.168.100.102 rm -rf ~/analyzers"
ssh dsns@192.168.100.102 "rm -rf ~/analyzers"
echo "dsns@192.168.100.103 rm -rf ~/analyzers"
ssh dsns@192.168.100.103 "rm -rf ~/analyzers"
echo "dsns@192.168.100.104 rm -rf ~/analyzers"
ssh dsns@192.168.100.104 "rm -rf ~/analyzers"
echo "dsns@192.168.100.105 rm -rf ~/analyzers"
ssh dsns@192.168.100.105 "rm -rf ~/analyzers"
echo "dsns@192.168.100.106 rm -rf ~/analyzers"
ssh dsns@192.168.100.106 "rm -rf ~/analyzers"
echo "dsns@192.168.100.107 rm -rf ~/analyzers"
ssh dsns@192.168.100.107 "rm -rf ~/analyzers"

echo "scp to dsns@192.168.100.102"
scp -r ~/analyzers dsns@192.168.100.102:~/
echo "scp to dsns@192.168.100.103"
scp -r ~/analyzers dsns@192.168.100.103:~/
echo "scp to dsns@192.168.100.104"
scp -r ~/analyzers dsns@192.168.100.104:~/
echo "scp to dsns@192.168.100.105"
scp -r ~/analyzers dsns@192.168.100.105:~/
echo "scp to dsns@192.168.100.106"
scp -r ~/analyzers dsns@192.168.100.106:~/
echo "scp to dsns@192.168.100.107"
scp -r ~/analyzers dsns@192.168.100.107:~/

#scp ~/analyzers/installAnalyzers.rb dsns@192.168.100.102:~/analyzers/
#scp ~/analyzers/installAnalyzers.rb dsns@192.168.100.103:~/analyzers/
#scp ~/analyzers/installAnalyzers.rb dsns@192.168.100.104:~/analyzers/
#scp ~/analyzers/installAnalyzers.rb dsns@192.168.100.105:~/analyzers/
#scp ~/analyzers/installAnalyzers.rb dsns@192.168.100.106:~/analyzers/
#scp ~/analyzers/installAnalyzers.rb dsns@192.168.100.107:~/analyzers/


#ssh dsns@192.168.100.102 "sudo ~/analyzers/installAnalyzers.rb"
#ssh dsns@192.168.100.103 "sudo ~/analyzers/installAnalyzers.rb"
#ssh dsns@192.168.100.104 "sudo ~/analyzers/installAnalyzers.rb"
#ssh dsns@192.168.100.105 "sudo ~/analyzers/installAnalyzers.rb"
#ssh dsns@192.168.100.106 "sudo ~/analyzers/installAnalyzers.rb"
#ssh dsns@192.168.100.107 "sudo ~/analyzers/installAnalyzers.rb"
