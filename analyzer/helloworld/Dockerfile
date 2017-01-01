# vim:set ft=dockerfile:
FROM ubuntu:xenial

# You shouldn't change this part, it install the required packages for secmap.
RUN apt-get update && \
	apt-get install -y --no-install-recommends ruby=1:2.3.0+1 ruby-dev=1:2.3.0+1 gcc=4:5.3.1-1ubuntu1 make=4.1-6 libc6-dev=2.23-0ubuntu5 && \
	gem install redis -v 3.3.2 && \
	gem install cassandra-driver -v 3.1.0 && \
	gem install docker-api -v 1.33.1 && \
	gem install sys-filesystem -v 1.1.7

# It will copy the entrypoint of your docker, please start your analyzer in docker-entrypoint.sh .
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

RUN mkdir -p /home/dsns/secmap 
VOLUME /home/dsns/secmap

