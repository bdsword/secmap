#!/bin/bash
set -e

clamd -c /etc/clamav/clamd.conf &
/home/dsns/secmap/analyzer/clamav/analyze.rb
