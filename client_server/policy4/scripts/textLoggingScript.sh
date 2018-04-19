#! /usr/local/bin/bash

# This script replaces logging by java, using log4j to write to P4L.log

# Here we'll just write several log messages to P4L.log
cat /var/log/nginx-access.log > P4L.log
echo '= = = = = = == = = = = = = ' >> P4L.log
cat /var/run/dmesg.boot >> P4L.log
echo '= = = = = = == = = = = = = ' >> P4L.log
tail -n50 /var/log/messages >> P4L.log


echo 'finished writing file'




