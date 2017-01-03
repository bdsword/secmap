# SECMAP

## Installation

1. Run the install script __install.sh__.

2. Copy and modified configuration files to fit your environment. Please read the comments for further helps.

  ```bash
  $ cp conf/cassandra/cassandra.example.yaml conf/cassandra/cassandra.yaml
  $ vim conf/cassandra/cassandra.yaml

  $ cp conf/secmap_conf.example.rb conf/secmap_conf.rb
  $ vim conf/secmap_conf.rb

  $ cp storage/redis_init.example.rb storage/redis_init.rb
  $ vim storage/redis_init.rb
  ```

3. Start the redia/cassandra service for the nodes.

  ```bash
  $ ./secmap.rb start redis
  $ ./secmap.rb start cassandra
  ```

## Usage

1. Call secmap to analyze all samples in a specific folder:

  ```bash
  $ cd secmap/input/read_dir
  $ ./readSamplesFromDir.rb <target folder path>
  ```

2. Find the taskUID for your analysis

  ```bash
  $ cat secmap/logs/taskUID_vs_filename.log
  ```

3. Read the report of your analysis

  ```bash
  $ cd secmap/lib
  $ ./getReportFromCassandra.rb <TaskUID> <AnalyzerType>
  ```

## Write an Analyzer

1. Create a directory for your analyzer under __ENV['ANALYZER_HOME']__.

  ```bash
  $ mkdir /var/analyzers/my_analyzer
  ```

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
