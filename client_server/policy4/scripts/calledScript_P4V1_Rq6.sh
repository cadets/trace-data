#! /usr/local/bin/bash

# remove any existing P4L.log file # Could make it so it checks, and removes only if needed.
rm -rf P4L.log
rm -rf tmp/p.txt
rm -rf tmp/latency.txt

# run java program to log messages (using log4j)  to a log file (P4L.log)

# TODO: Learn how to use log4j to log from java
# for now, instead of a java file, use a shell script that writes text
./textLoggingScript.sh    # produces `P4L.log` file

#Also downoad latency.txt from allendale:policyTest_CollectFrom/.
scp allendale:policyTest_CollectFrom/latency.txt tmp/latency.txt

# nbow wirte both sets fo text to an additional common file:
cat tmp/latency.txt P4L.log > tmp/p.txt

# upload P4L.log to allendale
scp tmp/p.txt allendale:policyTest_DropOff/.





