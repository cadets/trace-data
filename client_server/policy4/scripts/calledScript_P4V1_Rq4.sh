#! /usr/local/bin/bash

#NOTE: Assumes there are already directories called tmp/ tmp/h/ and home/ta3/ in this testscript directory,
#      into which files can be placed

# Maybe test for those needed directories here, and make them if they're not found.
#TODO: Add test for needed directories (tmp/ and home/ta3/. ), making them if not found

# download haxx.php to tmp/.
scp allendale:policyTest_CollectFrom/haxx.php tmp/.

# move tmp/haxx.php to tmp/h/nothaxx.txt
mv tmp/haxx.php tmp/h/nothaxx.txt

# gzip nothaxx.txt
gzip tmp/h/nothaxx.txt

# copy other files from /etc/mail into tmp/h
#cp /etc/mail/* tmp/h/.
pushd tmp
cp /etc/mail/* h/.

# tar czvf benign.tar.gz /tmp/h (includes files from etc/mail and nothaxx.php.gz, which is haxx.php)
tar -czvf benign.tar.gz h

# copy benign.tar.gz to home/ta3
cp benign.tar.gz ~/tc/CSPolicy4/home/ta3/.

# change directory over to that new one: ~/tc/CSPolicy4/home/ta3
pushd ~/tc/CSPolicy4/home/ta3/

# tar xzvf benign.tar.gz
tar -xzvf benign.tar.gz

# unzip h/nothaxx.gz   # `gunzip` or `gzip -d` do the same things
gzip -d h/nothaxx.txt.gz

# upload h/nothaxx.txt (which is really haxx.php)
scp h/nothaxx.txt allendale:policyTest_DropOff/.

# return to original directory
popd
echo "moved up to $PWD"
popd
echo "moved up to $PWD"


