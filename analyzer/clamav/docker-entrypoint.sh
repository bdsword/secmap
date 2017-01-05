#!/bin/bash
set -e

clamd -c /etc/clamav/clamd.conf &
/secmap/analyzer/clamav/clamav.rb
