# README.md

These scripts implement PolicyEnforcementDemo_Policy4_V1 from the BBN GitLab wiki.
The URL for this description is here:
https://git.tc.bbn.com/bbn/tc-policy-enforcement/wikis/Policy4V1


The scripts that implement these examples  expect the following directores to also exist where they are:

* tmp/
* tmp/h/ (it will be copied, zipped, and reconstituted by script ...Rq4.sh)
* home/ta3
* preExistingFiles/

To help with that, empty copies of those directories have bene placed in this scripts/ folder.  When using these scripts more than once, you will need to empty those folders to assure that writes do not hiccup trying to stomp on existing vefrsions of the files they are writing.

Within the directory preExistingFiles, the scripts expect to find the files:
Hyperloop_800px.jpg
msgLogExample.txt

In many cases, the scripts point to these locations explicitly.
The scripts and locations will need to be adapted if the placement locations are changed (e.g. to another user's home, or even to run directly under this trace-data/... directory.)