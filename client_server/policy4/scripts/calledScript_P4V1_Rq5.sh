#! /usr/local/bin/bash

# remove any existing P4L.log files.  # Could make it so it checks, removes only when needed.
rm -rf P4L.log
rm -rf tmp/p.txt
rm -rf tmp/latency.txt

# run java program to log messages (using log4j)  to a log file (P4L.log)

# TODO: Learn how to use log4j tolog from java
# for now, instead fo ajava file, use ascript that writes text
./textLoggingScript.sh    # produces `P4L.log` file

# upload h/nothaxx.txt (which is really haxx.php)
scp P4L.log allendale:policyTest_DropOff/.





