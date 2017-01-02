# SECMAP

## Installation

1. Install docker on your system.  
2. Add your account to docker group.
3. Run the install script __install.sh__.
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
  
6. Start/stop/status the redia/cassandra service for the nodes.
  > $ ./secmap.rb service RedisDocker start/stop/status  
  >
  > $ ./secmap.rb service CassandraDocker start/stop/status  

7. See more commands of redia/cassandra service.
  > $ ./secmap.rb service RedisDocker list
  >
  > $ ./secmap.rb service CassandraDocker list

8. Build analyzer docker.
  > $ ./secmap.rb analyzerDocker <analyzer docker name> build

9. Start/stop/status analyzer docker.
  > $ ./secmap.rb analyzerDocker <analyzer docker name> start/stop/status

10. See more commands of analyzer dockers.
  > $ ./secmap.rb analyzerDocker <analyzer docker name> list

11. See more command about redis/cassandra/pushtask client.
  > $ ./secmap.rb RedisCli/PushTask/CassandraCli list
