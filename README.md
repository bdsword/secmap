# SECMAP

## Installation

1. Install docker on your system.

2. Add your account to docker group.

3. Run the install script install.sh.

  ```bash
  $ ./install.sh
  ```

4. Copy and modified configuration file to fit your environment. Please read the comments for further helps.

  ```bash
  $ cp conf/secmap_conf.example.rb conf/secmap_conf.rb

  $ vim conf/secmap_conf.rb
  ```

5. Build redia/cassandra container.

  ```bash
  $ ./secmap.rb service RedisDocker pull
  $ ./secmap.rb service RedisDocker create

  $ ./secmap.rb service CassandraDocker pull
  $ ./secmap.rb service CassandraDocker create
  ```

## How to use

You can use the following commands to control secmap services on the nodes.

1. Start/stop/status the redia/cassandra service for the nodes.

  ```bash
  $ ./secmap.rb service RedisDocker start/stop/status

  $ ./secmap.rb service CassandraDocker start/stop/status
  ```

2. See more commands of redia/cassandra service.

  ```bash
  $ ./secmap.rb service RedisDocker list

  $ ./secmap.rb service CassandraDocker list
  ```

3. Set analyzer docker number.

  ```bash
  $ ./secmap.rb service Analyzer set <analyzer docker image name> <number>
  ```

4. Get existed analyzers.

  ```bash
  $ ./secmap.rb service Analyzer exist
  ```


5. See more command about redis/cassandra/pushtask client.

  ```bash
  $ ./secmap.rb RedisCli/PushTask/CassandraCli list  
  ```

## Using ansible

Using ansible to control those services are also recommended.

You can use the following command to control secmap services.

```bash
$ ansible -i inventory <hosts> -m raw -a "cd <secmap home> && ./secmap.rb service <service name> <action>"
```

Hosts can be any group of following (see inventory file below for more details):

```conf
# inventory
[redis]
192.168.100.1  ansible_port=22  ansible_user=dsns
[noredis]
192.168.100.2  ansible_port=22  ansible_user=dsns
192.168.100.3  ansible_port=22  ansible_user=dsns
192.168.100.4  ansible_port=22  ansible_user=dsns
192.168.100.5  ansible_port=22  ansible_user=dsns
192.168.100.6  ansible_port=22  ansible_user=dsns
[seed]
192.168.100.1  ansible_port=22  ansible_user=dsns
192.168.100.3  ansible_port=22  ansible_user=dsns
[notseed]
192.168.100.2  ansible_port=22  ansible_user=dsns
192.168.100.4  ansible_port=22  ansible_user=dsns
192.168.100.5  ansible_port=22  ansible_user=dsns
192.168.100.6  ansible_port=22  ansible_user=dsns
```

Examples:

```bash
# Check the redis status
$ ansible -i inventory redis -m raw -a "cd secmap && ./secmap.rb service RedisDocker status"

# Pull the redis docker from docker hub
$ ansible -i inventory redis -m raw -a "cd secmap && ./secmap.rb service RedisDocker pull"

# Create the docker instance
$ ansible -i inventory redis -m raw -a "cd secmap && ./secmap.rb service RedisDocker create"

# Get the existed analyzer
$ ansible -i inventory all -m raw -a "cd secmap && ./secmap.rb service Analyzer exist"

# Check the Analyzer status of specific ip/nodes
$ ansible all -i 192.168.100.1, -m raw -a "cd secmap && ./secmap.rb service Analyzer exist"
$ ansible all -i 192.168.100.2,192.168.100.3 -m raw -a "cd secmap && ./secmap.rb service Analyzer exist"
```

See the [How to use](#how-to-use) for more details.
