readme.md

# Client - Server operation traces, with scripts to repeatably produce them
## New files (more current for engagement E3), added 4 April 2018


Three directories for client-server trace production and storage:
* scripts 	  set of scripts that capture CADETS *.json traces and command specific client or server actions
* cadets 	  a place to put CADETS *.json traces, output from the dtrace audit.d script called from above directory
* cdm 		  a place to put translated CADETS traces, once converted to proper .cdm.bin and .cdm.json formats 

The trace capture script run to start dtrace's audit.d is: `oneLineAuditScript2Args.sh`.
It depends upon the CADETS/dtrace-scripts file `audit.d`.
Running these scripts assumes we have CADETS instrumentation installed on the machine.
(This allows audit.d to capture traces with the CADETS preferred probes.)

Translation of the produced CADETS *.json trace output to CDM *.cdm.bin or *.cdm.json requires CDM translator python code from these repos:
* ta1-integration-cadets
* ta3-api-bindings-python
* ta3-serialization-schema


# Scripts folder documentation

This directory provides scripts to make repeatable the set of calls to launch dtrace auditing of client and server side activites on a CADETS system.

Scripts allow:
0. Calling of dtrace-scripts/audit.d to run dtrace appropriate to CADETS
1. Calling for Client role activity to be monitored, requesting and receiving data from another server
2. Calling for Server role activity to be monitored, ssh-ing to another machine to be the client, requesting data of this machine
3. Calling for Client and Server role activities to be monitored, requesting and receiving data from the same host, via hostname (As opposed to just local path)

For each of those (1-3) role combinations, there are 3 cases presently:
A. CURL, collecting/providing a(n nginx) web-served file from a server named in the script
B. Links, collecting/providing a(n nginx) web-served file from a server named in the script
C. Git clone, collecting/providing the cadets-ci repo from server and address named in the script

# Notes on how the scripts work

- client scripts
Some notes on how the `calledScript_client*.sh scripts work:
To act as client, the host on which the tracing is being preformed launches client software such as:
* `git clone <hostname>:path/to/dir/cadets-ci`  to request and receive a clone of the cadets-ci repo
* `CURL http://allendale.musec.engr.mun.ca` to request and receive the web file available a that front door address 
* `links http://allendale.musec.engr.mun.ca`

- server scripts (how `calledScript_serve*.sh` scripts work):
For machineA To act as server, in response to controlled calls, _serve*.sh scripts contain an ssh call from MachineA to MachineB.
MachineB then issues the same client calls as mentioned above, bu tnow to the server addresses on Machine A.

- clientAndServer scripts
A third version includes the client calling to itself, via a network socket.
This allows both client and server activity to be observed and traced simultaneously on one machine.

- trace launching scripts:
audit.d launching script + selection of calledScript_*.sh client server scripts to trace
The main trace calling routine is `oneLineAuditScript2Args.sh`
It requires the user have sudo privilege passwords (requested during script running) to launch the audit.d dtrace script.
The `...2Args...` in the script name are (in currently expected order):
<calledScript*.sh> ($1):  a string that could directly launch a script by its name (and global path to reach and launch it)
<outputFile.json>  ($2):  a string that provides an output file name and location to which it can and should be written

The call to launch this, is: 
```./oneLineAuditScript2Args.sh $1 $2```
Current call structure to run a tracing of activity controlled by the various client-server scripts:
```./oneLineAuditScript2Args.sh '</full/path/name/of/ClientServerScript.sh>' '</full/destination/path/name/of/output_file.json>'```
example (from within the scripts:
```./oneLineAuditScript2Args.sh './calledScript_serveLinks.sh' 'trace_serveLinks.json'```

# privileges required:
- ssh-agent identity (identities)
Every calledScript requires passphrase entry to support an `ssh-agent`.
Only `calledScript_server*.sh` scripts actually use this.
In client cases, some passphrase calls are unnecessary.  The scripts can be streamlined to remove many of them.

- sudo 
Any `sudo` used in the scripts will require a sudo pasword unless the /etc/sudoers file allows otherwise

# User selection
Right now all the scripts expect (and in fact often assume or even call explicitly) that skalik will be the user.  As a result, the relevant passwords and passphrases from skalik are needed to run and access machines or achieve necessary privileges.


Current script Implementations:
All scripts assume they are on blackmarsh3, running as `calledScript_<ROLE><PROGRAM>.sh`
where <ROLE> can be {`client` , `server`  or `clientAndServer`}
and <PROGRAM> is one of {'CURL ...', 'git clone ...', or 'links ...'} as mentioned above
There is an audit.d launching script called `oneLineAuditScript2Args.sh`.
--> It takes two arguments (without any checking a this point).  They should be:
--> a `calledScript_<ROLE><PROGRAM>.sh` script first, and then
--> an output file name, of the form: trace_<ROLE><PROGRAM>.json  (e.g. `trace_serveLinks.json`)


# CADETS traces folder documentation

The `cadets` folder contains CADETS .json traces resulting from running the `oneLineAuditScript2Args.sh`.
These files are named to indicate which <role(s)> the traced machine is playing in the client - server activity, and which application (<program>) is being traced.

The .json files contain one line per call during the traced activity.
These calls include all CADETS instrumented activity on the traced machine, and tpyically includes backgorund activity running during th etrace, as well as activity specifically comanded.

The .json files in here cna be translated to cdm.bin files for ADAPT testing and Transparent Computing analysis, using the translator services provided by bbn.

The repositories of code to translate these .json files to .cdm files can be found here:
* ta1-integration-cadets
* ta3-api-bindings-python
* ta3-serialization-schema


# CDM (translated trace) folder documentation

The `cdm` folder is where files oputput from the cdm translator code should be placed.
These are the trace files, now in standardized common data model (CDM) format, appropriate for analysis by other performers, and for testing wth the ADAPT-tester tool.
ADAPT-tester can be found at this address: (TODO: adapt-tester.jar Provider URL TO BE FILLED IN)

Details of the CDM format can be found on readme's in the translator directories.



