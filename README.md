# SECMAP

## Installation

1. Install docker on your system.  
2. Add your account to docker group.
3. Run the install script __install.sh__.
4. Copy and modified configuration files to fit your environment. Please read the comments for further helps.
  > $ cp conf/secmap_conf.example.rb conf/secmap_conf.rb
  >
  > $ vim conf/secmap_conf.rb
  
5. Start the redia/cassandra service for the nodes.
  > $ ./secmap.rb start redis
  >
  > $ ./secmap.rb start cassandra
