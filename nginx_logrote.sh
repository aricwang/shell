#!/bin/bash
# This scipt run at 00:00
# The Nginx logs path
logs_path="/data0/log/nginx/"
PIDFILE=/var/run/nginx.pid
ACCESS_LOG="${logs_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")/access_$(date -d "yesterday" +"%Y%m%d").log"
ERROR_LOG="${logs_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")/error_$(date -d "yesterday" +"%Y%m%d").log"

mkdir -p ${logs_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")/

mv ${logs_path}access.log $ACCESS_LOG
mv ${logs_path}error.log $ERROR_LOG

kill -USR1 `cat $PIDFILE`

#gzip
/bin/gzip -9 $ACCESS_LOG
/bin/gzip -9 $ERROR_LOG

#rm
find ${logs_path} -name "*.log.gz" -mtime +7|xargs rm -f