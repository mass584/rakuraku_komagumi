#!/bin/bash
bundle install
rm -f tmp/pids/server.pid
bin/delayed_job start -n 1
bin/rails s -b 0.0.0.0 -p 8000