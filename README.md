# SECMAP

## Installation

1. Run the install script __install.sh__.
2. Copy and modified configuration files to fit your environment. Please read the comments for further helps.
  > $ cp conf/cassandra/cassandra.example.yaml conf/cassandra/cassandra.yaml
  >
  > $ vim conf/cassandra/cassandra.yaml
  
  
  > $ cp conf/secmap_conf.example.rb conf/secmap_conf.rb
  >
  > $ vim conf/secmap_conf.rb
  
  > $ cp storage/redis_init.example.rb storage/redis_init.rb
  >
  > $ vim storage/redis_init.rb

3. Start the redia/cassandra service for the nodes.
  > $ ./secmap.rb start redis
  >
  > $ ./secmap.rb start cassandra
