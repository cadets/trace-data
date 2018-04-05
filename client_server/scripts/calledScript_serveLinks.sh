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

#ssh -t skalik@allendale 'cd testRcv2; links http://blackmarsh3.musec.engr.mun.ca & ; sleep 1; kill $!'
ssh -t skalik@allendale 'cd testRcv2; links http://blackmarsh3.musec.engr.mun.ca'
#ssh -t skalik@allendale 'cd testRcv2; ./runAndKillLinks.sh' 
#echo "killing ssh-agent"
#eval `ssh-agent -k`
