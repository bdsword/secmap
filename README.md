# SECMAP

## Installation

1. Run the install script __install.sh__.
2. Modify the configuration files. Please read the comments for further helps.
  > $ vim conf/cassandra/cassandra.yaml
  >
  > $ vim lib/common.rb
  >
  > $ vim storage/redis_init.rb

3. Start the redia/cassandra service for the nodes.
  > $ ./secmap.rb start redis
  >
  > $ ./secmap.rb start cassandra
