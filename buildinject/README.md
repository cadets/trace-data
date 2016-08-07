BuildInject Scenario
====================

This scenario models an attack in which the attacker gains login credentials
and is able to compromise some key files on the build server. BuildInject is
meant to model the Boston Fusion Software Company scenario, where a backdoor is
inserted into an application.

The attacker creates a backdoor by replacing the system `crt1.o` object
(`/usr/lib/crt1.o`). `crt1.o` defines the `_start` symbol, the entry point
for executables. `_start` runs before `main()`, so it is a good place for
an attacker to take control.

Once replaced, the backdoored `/usr/lib/crt1.o` object
file is linked into every executable the compiler builds (unless
non-standard linker options are used).

Script
======

This script assumes the build server is located at `10.0.6.1`.

### Pre-attack
* Bob is logged-in through ssh into a build server and builds a "Hello World"
  application (hello.c). The application contains a bug (echoing "Hello Wrld"
  instead of the correct greeting)

~~~
cc -o hello hello.c
~~~

* Bob runs the executable normally and discovers the bug

~~~
./hello
~~~

* Bob logs out (he then puts the bug on his TODO list).

~~~
exit
~~~

* Bob connects again through ssh and edits hello.c to echo "Hello World". He
then logs out

~~~
ssh bob@10.0.6.1
vi hello.c
cc -o hello hello.c && ./hello
exit
~~~

* Alice and Eve also ssh in, compile their own programs of interest and run
them. For the purposes of this scenario, they can build other binaries from
hello_test.c and hello_2.c

~~~
ssh alice@10.0.6.1
cc -o hello_test hello_test.c && ./hello_test
exit

ssh eve@10.0.6.1
cc -o hello_2 hello_2.c && ./hello_2
exit
~~~

### Attack

* Attacker has stolen the credentials for Bob's account. The attacker
  will `scp` the backdoored `crt1.o` file to the build server
  (`10.0.6.1`). (NB: The attacker does not run BuildInject on the
  build server in this scenario. Instead, the attacker will use a
  different machine to run BuildInject and create the backdoored
  `crt1.o`)

~~~
scp crt1-exploit.o bob@10.0.6.1:~/crt1.o
~~~

* Attacker logs into build server (`10.0.6.1`) and copies the
  `crt1.o` file to the system path (`/usr/lib`), so that the backdoor
  will be inserted into newly built executables.

~~~
ssh bob@10.0.6.1
sudo cp ./crt1.o /usr/lib
exit
~~~

### Post-attack

* Bob attempts to build a "Hello World" application. This application
  will be backdoored.

~~~
ssh bob@10.0.6.1
cc -o hello hello.c
~~~

* When Bob runs the executable, the backdoor will write the args to
`/tmp/runlog`.

~~~
./hello
~~~

* Alice and Eve also ssh in and compile fresh copies of their applications:

~~~
ssh alice@10.0.6.1
cc -o hello_test hello_test.c && ./hello_test
exit

ssh eve@10.0.6.1
cc -o hello_2 hello_2.c && ./hello_2
exit
~~~


Traces
======

* buildinject.json -  Trace in CADETS format
* buildinject.json.CDM.json -  Trace in CDM json format
