#! /usr/local/bin/bash

#su -l skalik

whoami
echo

#echo "setting up ssh-agent.  Will need your key."
#eval `ssh-agent`
#ssh-add ~/.ssh/bm34alndl_id_rsa

#echo "sleeping for 2 secs.."
#sleep 2 
#echo

 echo "beginning git clone request for cadets-ci"
# ssh -t skalik@allendale 'cd testRcv2; git clone blackmarsh3:tc/cadets-ci'   # to serve to client elsewhere
sudo -u skalik git clone allendale:testRcv2/cadets-ci localRcv1/cadets-ci     # to be client for server elsewhere
#git clone blackmarsh3:tc/cadets-ci localRcv2/cadets-ci'     # to serve to own client

#echo "killing ssh-agent"
#eval `ssh-agent -k`
