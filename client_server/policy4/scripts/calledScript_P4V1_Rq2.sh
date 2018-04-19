#! /usr/local/bin/bash

# copy last 50 lines of messages file to tmp/newfile.txt
tail -n5 /var/log/messages > tmp/newfile.txt

# upload newfile.txt to allendale.
scp tmp/newfile.txt allendale:policyTest_DropOff/.

