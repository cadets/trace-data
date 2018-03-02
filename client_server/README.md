README.md

Traces provided (in `cdm` folder) are CDM18 translations of original dtrace audit.d observations from metaio enabled freeBSD CURRENT-12 CADETS system (in `cadets` folder).

Traces `git clone <hostname>:<reponame>` client and server actions by blackmarsh3.
These actions include blackmarsh3 acting as:
1. client requesting `git clone allendale:~/freebsd` from allendale (git_clone_client.*)
2. server responding to `git clone blackmarsh3:~/testdir/freebsd` from allendale (git_clone_server.*)
3. client and server on same transaction, responding to `git clone localhost:~/testdir/freebsd` to blackmarsh3:~/testdir2/. (git_clone_client_and_server.*)

Two primary subfolders include:
1. cadets: raw dtrace output traces from audit.d (*.json)
2. cdm: translation of those raw dtrace output traces to cdm18 format (*.cdm.json : human interpretable file ; *.cdm.bin : machine interpretable version)

Traces collected between February 26th and 28th, 2018.


