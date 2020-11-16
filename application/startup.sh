#!/bin/bash
bundle install
rm -f tmp/pids/server.pid
bin/rails s -b 0.0.0.0 -p 3000