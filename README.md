# SECMAP

## Installation

1. Install docker on your system.  
2. Add your account to docker group.
3. Run the install script install.sh.
  > $ ./install.sh  

4. Copy and modified configuration file to fit your environment. Please read the comments for further helps.
  > $ cp conf/secmap_conf.example.rb conf/secmap_conf.rb  
  >
  > $ vim conf/secmap_conf.rb  

5. Build redia/cassandra container.
  > $ ./secmap.rb service RedisDocker pull  
  > $ ./secmap.rb service RedisDocker create  
  >
  > $ ./secmap.rb service CassandraDocker pull  
  > $ ./secmap.rb service CassandraDocker create  

6. Build analyzer docker container by Dockerfile.
  > $ ./secmap.rb analyzerDocker <analyzer docker name> build  
  > $ ./secmap.rb analyzerDocker <analyzer docker name> create

## How to use
  
1. Start/stop/status the redia/cassandra service for the nodes.
  > $ ./secmap.rb service RedisDocker start/stop/status  
  >
  > $ ./secmap.rb service CassandraDocker start/stop/status  

2. See more commands of redia/cassandra service.
  > $ ./secmap.rb service RedisDocker list  
  >
  > $ ./secmap.rb service CassandraDocker list  

3. Start/stop/status analyzer docker.
  > $ ./secmap.rb analyzerDocker <analyzer docker name> start/stop/status  

4. See more commands of analyzer dockers.
  > $ ./secmap.rb analyzerDocker <analyzer docker name> list  

5. See more command about redis/cassandra/pushtask client.
  > $ ./secmap.rb RedisCli/PushTask/CassandraCli list  
