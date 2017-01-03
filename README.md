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

## Usage

1. 呼叫secmap開始分析

  > $ cd secmap/input/read_dir (一定要cd進去)

  > $ ./readSamplesFromDir.rb <samples所在目錄>

2. 找出欲查看之sample對應的Task UID

  > $ cat secmap/logs/taskUID_vs_filename.log

3. 查看該UID對應的分析結果

  > $ cd secmap/lib (一定要cd進去)

  > $ ./getReportFromCassandra.rb <Task UID> <AnalyzerType>


## Write an Analyzer

1. Create a directory for your analyzer under __ENV['ANALYZER_HOME']__.

  > $ mkdir /var/analyzers/my_analyzer

2. Create a file named __config__ under your analyzer directory, and 3 options should be set inside the config file:

  - TYPE: The name of your analyzer.

  - LOG: The output log file of your analyzer.

  - COMMAND: The command to run/start your analyzer.


- Example config files:

  ```bash
  # File path: /var/analyzers/my_analyzer/config
  TYPE=MY_ANALYZER
  LOG=RESULT.log
  COMMAND=/var/analyzers/my_analyzer/start.sh
  ```

  ```bash
  # File path: /var/analyzers/my_analyzer/start.sh
  echo "DEMO Result!!!" > RESULT.log
  ```
