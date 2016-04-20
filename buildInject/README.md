BuildInject Scenario
====================

This scenario makes use of Kudu's BuildInject tool. BuildInject is
meant to model the Boston Fusion Software Company scenario, where a
backdoor is inserted into an application.

BuildInject creates a backdoor in the system `crt1.o` object
(`/usr/lib/crt1.o`). `crt1.o` defines the `_start` symbol, the entry point
for executables. `_start` runs before `main()`, so it is a good place for
an attacker to take control.

Once BuildInject is applied, the backdoored `/usr/lib/crt1.o` object
file is linked into every executable the compiler builds (unless
non-standard linker options are used).

Script
======

* Attacker has stolen the credentials for Bob's account. The attacker
  will `scp` the backdoored `crt1.o` file to the build server
  (`192.168.1.101`). (NB: The attacker does not run BuildInject on the
  build server in this scenario. Instead, the attacker will use a
  different machine to run BuildInject and create the backdoored
  `crt1.o`)

~~~
scp /home/arun/tc/obj/usr/home/arun/tc/freebsd/lib/csu/amd64/crt1.o bob@192.168.1.101:~
~~~

* Attacker logs into build server (`192.168.1.101`) and copies the
  `crt1.o` file to the system path (`/usr/lib`), so that the backdoor
  will be inserted into newly built executables.

~~~
ssh bob@192.168.1.101
sudo cp ./crt1.o /usr/lib
~~~

* Bob attempts to build a "Hello World" application. This application
  will be backdoored.

~~~
cc -o hello hello.c
~~~

* When Bob runs the executable, the backdoor will write the args to
`/tmp/runlog`.


~~~
./hello
~~~

Traces
======

* buildinject.json -  Trace in CADETS format
* buildinject.json.CDM.json -  Trace in CDM json format
* CDM Traces forthcoming
