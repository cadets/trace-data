#! /usr/local/bin/bash

echo "setting up ssh-agent.  Will need your key."
eval `ssh-agent`
ssh-add ~/.ssh/bm34alndl_id_rsa

echo "sleeping for 2 secs.."
sleep 2 
echo

echo "starting audit.d call (into dtrace) of $1"
#sudo -E ~/tc/dtrace-scripts/audit.d -c "./calledScript2.sh" -o ~/tc/CSscriptDevTest/foo6.json $(sysctl -n kern.hostuuid)

# eval "sudo -E ~/tc/dtrace-scripts/audit.d -c $1 -o $2 $(sysctl -n kern.hostuuid)"
eval "sudo -E ~/tc/dtrace-scripts/audit.d -c 'su skalik -c $1' -o $2 $(sysctl -n kern.hostuuid)"
# # Name of test output file: ~/tc/CSscriptDevTest/foo6.json

# # test calling git script without tracing
#echo 'starting test of called script'
#sudo -E ./calledScript2.sh  # tests
#sudo -E ./calledScript_serveLinks.sh  # tests 
#eval "sudo -E $1"
echo
echo 'finsihed called script test and audit.d call'

#echo 'finished audit.d call'

echo "killing ssh-agent"
eval `ssh-agent -k`
