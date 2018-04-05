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

#ssh -t skalik@allendale 'cd testRcv2; curl http://blackmarsh3.musec.engr.mun.ca > collectedByCURLFromNGINX.html '  # go to allendale and call for nginx served file from blackmarsh3
#curl http://allendale.musec.engr.mun.ca > collectedByCURLFromNGINXOnAllednale.html        # call for nginx served file form allendale
curl http://blackmarsh3.musec.engr.mun.ca > collectedByCURLFromNGINXOnBlackmarsh3.html    # call fro nginx served file from self

#echo "killing ssh-agent"
#eval `ssh-agent -k`
