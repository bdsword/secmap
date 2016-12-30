#!/bin/sh

apt update
apt install ruby=1:2.3.0+1
gem install redis -v 3.3.2
gem install cassandra-driver -v 3.1.0
gem install docker-api -v 1.33.1
gem install sys-filesystem -v 1.1.7
