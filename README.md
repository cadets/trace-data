# CADETS Trace Data

The current CADETS trace serialization format is an array of JSON
event objects. A translator exists to convert this format into CDM.

Here is an example CADETS trace event:

```json
[

  {
	"event": "audit:event:aue_open_rwtc:",
	"time": 1469039289662056556,
	"pid": 2126,
	"ppid": 2124,
	"tid": 100102,
	"uid": 8314,
	"exec": "ld",
	"subjprocuuid": "b5b79f21-4ea7-11e6-ab31-44a842348b1c",
	"arg_objuuid1": "2290610f-dee2-215b-a2de-1a77eb217137",
	"ret_objuuid1": "2290610f-dee2-215b-a2de-1a77eb217137",
	"upath1": "/usr/lib/crt1.o",
	"retval": 4
  },

]
```

Each event will have a subset of following attributes:

* _event_: Event name. We use DTrace's naming convention for events
  (<dtrace provider>:<module>:<function>:<probe name>). For example,
  "audit:event:aue_open_rwtc:" is an event that is triggered when the
  FreeBSD `open()` system call is entered. The probe name is optional --
  not all events will include it.
* _time_: The time the event occurred expressed as nanoseconds since 00:00
  Universal Coordinated Time, January 1, 1970.
* _pid_: The ID of the process that generated the event.
* _subjprocuuid_: A UUID of the process that generated the event.
* _subjthruuid_: A UUID of the thread that generated the event.
* _ppid_: The ID of the parent of the process that generated the
  event.
* _tid_: The ID of the thread that generated the event.
* _uid_: The ID of the user that generated the event.
* _exec_: The name of the executable associated with this event.
* _fd_: A filesystem descriptor (fd) input (argument) associated with this event.
* _address_: The IPv4/v6 address associated with an event.
* _port_: The network port associated with an event.
* _procuuid_: A UUID for a process affected by this effect
* _upath1_: A path input associated with the event.
* _upath2_: A second path input associated with the event.
* _arg_objuuid1_: A UUID associated with an object that is an input
  (argument) to this event
* _arg_objuuid2_: A UUID associated with a second object
  that is an input (argument) to this event
* _ret_objuuid1_: A UUID associated with an object
  that is an output (return value) of this event
* _ret_objuuid2_: A UUID associated with a second object that is an
  output (return value) of this event
* _retval_: A return value associated with the event. For filesystem
  calls, the retval often holds the file descriptor returned.

Specific applications may have extra attributes:

* _query_: The database query associated with the event (for Postgresql)
* _request_: The HTTP request associated with the event (for nginx)

# CDM Mapping

Our traces are converted to CDM format on a per event record basis. Currently,
each event in a CADETS trace is converted to a corresponding event entry in the CDM format.
If necessary, related objects are also created, such as files, users, or
processes.

Take this short trace:
```json
[
  {"event": "audit:event:aue_unlink:", "time": 1469212266719943874, "pid": 3555, "ppid": 3554, "tid": 100153, "uid": 0, "exec": "remove_file", "subjprocuuid": "73bc6807-503a-11e6-b8c7-080027889132", "arg_objuuid1": "ea7eea24-097f-cf5b-bf09-a3843bcf40b6", "upath1": "/usr/home/strnad/unit_tests/temp.out", "retval": 0}
, {"event": "audit:event:aue_exit:", "time": 1469212266719943874, "pid": 3555, "ppid": 3554, "tid": 100153, "uid": 0, "exec": "remove_file", "subjprocuuid": "73bc6807-503a-11e6-b8c7-080027889132", "retval": 0}
]
```

In CDM format, it looks like this
[remove_file.cdm.json](./ripe_unit_tests_traces/cdm/remove_file.cdm.json). This
simple trace becomes a graph with 2 events, 4 edges, and 3 nodes describing the
running process, the user, and the file being removed.

Events are converted to known CDM events when possible, and are otherwise left
as OS_UNKNOWN or APP_UNKNOWN depending on the source of the event.

Any information from the CADETS trace that does not have a corresponding place
in the CDM trace is copied into the properties field as a map of fields to
values.

File objects are created when they are first referenced. File names are
associated with file objects on opens, but may not be included for each read or
write. Versions are incremented on writes, but versions may be created at
version -1 at any time to associate a file path with the object. Sometimes
different paths will associate to the same file object, and sometimes the same
path will refer to different file objects over time.

When a process starts executing a new program, the CDM trace will show a link
between the file being executed and the exec event. This provides the full path
to the program upon start of execution.

For example:
```json
{"datum": {"timestampMicros": 1469212271398110, "uuid": "00000000000000030000000000000019", "sequence": 25, "source": "SOURCE_FREEBSD_DTRACE_CADETS", "threadId": 100259, "type": "EVENT_EXECUTE", "properties": {"subjprocuuid": "76dd6962-503a-11e6-b8c7-080027889132", "arg_objuuid1": "c63c9e57-55b6-7d59-b655-e198f97d106e", "probe": "", "module": "event", "call": "aue_execve", "provider": "audit", "path": "/usr/local/bin/wget", "retval": "0", "upath1": "/usr/local/bin/wget"}}, "CDMVersion": "13"}
{"CDMVersion": "13", "datum": {"baseObject": {"source": "SOURCE_FREEBSD_DTRACE_CADETS", "properties": {}}, "uuid": "000000000000000649883dfd38c0a873", "url": "/usr/local/bin/wget", "isPipe": false, "version": 1, "properties": {}}}
{"CDMVersion": "13", "datum": {"fromUuid": "000000000000000649883dfd38c0a873", "toUuid": "00000000000000030000000000000019", "properties": {}, "timestamp": 1469212271398110, "type": "EDGE_FILE_AFFECTS_EVENT"}}
```

## Identifying Files


When a file is opened in a CADETS trace, a version 1 (or -1 if the file has
already been referenced) is created for the file. A version of -1 does not
reflect a change to the file - it simply provides a path for the file. On
reads and writes, the url is an empty string(""), since the url is not an
optional field.

On opens, reads, and closes, an EDGE_FILE_AFFECTS_EVENT will be generated
connecting the file and event. On writes, EDGE_EVENT_AFFECTS_FILE will be
generated instead. On each write, the version is incremented, but the uuid does
not change.

These edges link to the uuid for the file. While the latest version of the file 
may not specify the file path, earlier versions will. The only exception is in 
the case of files opened before tracing begins. In that case, it is possible no 
file name will be included.

Note that it is possible for two different paths to refer to the same uuid -
these are still the same file. Either both paths point to the same location on
the underlying file system, or the path has changed. It is also possible to
have two separate uuids for the same url. This can happen when a file is
deleted and a new file with the same name is created.

In this example, you can see that /tmp/hello-cf9520.o is opened. It has the
uuid "fbf007a0ee6cea5bacee7b1fdbea745".  UUID
"fbf007a0ee6cea5bacee7b1fdbea745" is then read.

Example:
```json
{"datum": {"timestampMicros": 1469039289690063, "uuid": "000000000000000300000000000000ef", "sequence": 239, "source": "SOURCE_FREEBSD_DTRACE_CADETS", "threadId": 100102, "type": "EVENT_OPEN", "properties": {"exec": "ld", "errno": "0", "flags": "0", "mode": "438", "call": "aue_open_rwtc", "retval": "9", "upath1": "/tmp/hello-cf9520.o"}}, "CDMVersion": "13"}
{"datum": {"baseObject": {"source": "SOURCE_FREEBSD_DTRACE_CADETS", "properties": {}}, "uuid": "fbf007a0ee6cea5bacee7b1fdbea7456", "url": "/tmp/hello-cf9520.o", "isPipe": false, "version": -1, "properties": {}}, "CDMVersion": "13"}
{"datum": {"timestampMicros": 1469039289691083, "uuid": "000000000000000300000000000000f2", "sequence": 242, "source": "SOURCE_FREEBSD_DTRACE_CADETS", "threadId": 100102, "type": "EVENT_READ", "properties": {"errno": "0", "fd": "9", "call": "aue_read", "retval": "1216", "exec": "ld"}}, "CDMVersion": "13"}
{"datum": {"fromUuid": "fbf007a0ee6cea5bacee7b1fdbea7456", "toUuid": "000000000000000300000000000000f2", "properties": {}, "timestamp": 1469039289691083, "type": "EDGE_FILE_AFFECTS_EVENT"}, "CDMVersion": "13"}
```

# Identifying SSH Sessions

When analysing traces, it may be useful to identify separate SSH sessions as
well as identifying the IP address initiating the connection. Reads and writes
from `/dev/tty` or `/dev/pts/*` indicate the data came from a console.

The read and write events do not provide enough information by themselves to
identify the IP address, however, by tracing the process and its parent
processes back to the initial ssh connection, the IP address can be identified.
A connection from the relevant IP address is accepted, and other connections
are also made using connect (only the accept syscall is shown below).  

Unfortunately, ssh forks numerous times, so it may take traversing a number of
links to locate the IP address. 

In the sample below, the ssh session was initiated from 192.168.1.1. I can
determine that by starting with the read event, finding the process running it
(5c1274b56ec811e693e844a8421f8dc6), finding its parent process
(5a1260586ec811e693e844a8421f8dc6), and its parent process
(68436e4258c411e6937744a8421f8dc6). This process is the ssh daemon. Looking at
this process I can see that it accepted a connection from 192.168.1.1 and then
quickly forked off the process chain that I just followed. The ssh processes
forked also connected to 192.168.1.1 numerous times.

Note that
this sample was generated and then modified by hand to improve readability - it
is not exactly what would be generated.

```json
{"datum": {"properties": {}, "uuid": "68436e4258c411e6937744a8421f8dc6", "pid": 868, "type": "SUBJECT_PROCESS", "ppid": 1, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}, "CDMVersion": "13"}
...
{"datum": {"properties": {"address": "192.168.1.1", "subjprocuuid": "68436e4258c411e6937744a8421f8dc6", "port": "29348", "arg_objuuid1": "6843b94f58c411e6937744a8421f8dc6", "exec": "sshd", "call": "aue_accept", "retval": "5", "fd": "4", "arg_objuuid2": "5a1220326ec811e693e844a8421f8dc6"}, "uuid": "e1c8ad6c29ba56e68173f74644aa9e55", "timestampMicros": 1472571746503006, "threadId": 100094, "type": "EVENT_ACCEPT", "source": "SOURCE_FREEBSD_DTRACE_CADETS", "sequence": 0}, "CDMVersion": "13"}
{"datum": {"properties": {}, "srcPort": -1, "destAddress": "192.168.1.1", "srcAddress": "localhost", "uuid": "357a3fc1a1855ff2ad9d57376aada9c8", "baseObject": {"properties": {}, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}, "destPort": 29348}, "CDMVersion": "13"}
{"datum": {"properties": {}, "fromUuid": "e1c8ad6c29ba56e68173f74644aa9e55", "toUuid": "357a3fc1a1855ff2ad9d57376aada9c8", "type": "EDGE_EVENT_AFFECTS_NETFLOW", "timestamp": 1472571746503006}, "CDMVersion": "13"}
...
{"datum": {"properties": {"subjprocuuid": "68436e4258c411e6937744a8421f8dc6", "exec": "sshd", "ret_objuuid1": "5a1260586ec811e693e844a8421f8dc6", "call": "aue_fork", "retval": "5334", "arg_pid": "5334", "ret_objuuid2": "5a1260586ec811e693e844a8421f8dc6"}, "uuid": "d1d6679cdd475179908ef14018be1c6a", "timestampMicros": 1472571746503878, "threadId": 100094, "type": "EVENT_FORK", "source": "SOURCE_FREEBSD_DTRACE_CADETS", "sequence": 1}, "CDMVersion": "13"}
{"datum": {"properties": {}, "fromUuid": "d1d6679cdd475179908ef14018be1c6a", "toUuid": "68436e4258c411e6937744a8421f8dc6", "type": "EDGE_EVENT_ISGENERATEDBY_SUBJECT", "timestamp": 1472571746503878}, "CDMVersion": "13"}
{"datum": {"properties": {}, "uuid": "5a1260586ec811e693e844a8421f8dc6", "pid": 5334, "type": "SUBJECT_PROCESS", "ppid": 868, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}, "CDMVersion": "13"}
{"datum": {"properties": {}, "fromUuid": "5a1260586ec811e693e844a8421f8dc6", "toUuid": "68436e4258c411e6937744a8421f8dc6", "type": "EDGE_SUBJECT_HASPARENT_SUBJECT", "timestamp": 1472571746503878}, "CDMVersion": "13"}
...
{"datum": {"properties": {"subjprocuuid": "5a1260586ec811e693e844a8421f8dc6", "exec": "sshd", "ret_objuuid1": "5c1274b56ec811e693e844a8421f8dc6", "call": "aue_fork", "retval": "5337", "arg_pid": "5337", "ret_objuuid2": "5c1274b56ec811e693e844a8421f8dc6"}, "uuid": "986e989b2fd55b56a996de49648b3e72", "timestampMicros": 1472571749859869, "threadId": 100188, "type": "EVENT_FORK", "source": "SOURCE_FREEBSD_DTRACE_CADETS", "sequence": 2}, "CDMVersion": "13"}
{"datum": {"properties": {}, "fromUuid": "986e989b2fd55b56a996de49648b3e72", "toUuid": "5a1260586ec811e693e844a8421f8dc6", "type": "EDGE_EVENT_ISGENERATEDBY_SUBJECT", "timestamp": 1472571749859869}, "CDMVersion": "13"}
{"datum": {"properties": {}, "uuid": "5c1274b56ec811e693e844a8421f8dc6", "pid": 5337, "type": "SUBJECT_PROCESS", "ppid": 5334, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}, "CDMVersion": "13"}
{"datum": {"properties": {}, "fromUuid": "5c1274b56ec811e693e844a8421f8dc6", "toUuid": "5a1260586ec811e693e844a8421f8dc6", "type": "EDGE_SUBJECT_HASPARENT_SUBJECT", "timestamp": 1472571749859869}, "CDMVersion": "13"}
...
{"datum": {"properties": {"upath1": "/dev/tty", "subjprocuuid": "5c1274b56ec811e693e844a8421f8dc6", "exec": "sshd", "ret_objuuid1": "c0e6049062be7b5abe626f2dba7ba087", "fd": "-100", "call": "aue_openat_rwtc", "retval": "11", "flags": "1", "mode": "0", "arg_objuuid1": "c0e6049062be7b5abe626f2dba7ba087"}, "uuid": "2963b6532a405451b63d6c17688029f5", "timestampMicros": 1472571749998870, "threadId": 100075, "type": "EVENT_OPEN", "source": "SOURCE_FREEBSD_DTRACE_CADETS", "sequence": 4}, "CDMVersion": "13"}
{"datum": {"isPipe": false, "properties": {}, "version": 1, "uuid": "c0e6049062be7b5abe626f2dba7ba087", "url": "/dev/tty", "baseObject": {"properties": {}, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}}, "CDMVersion": "13"}
{"datum": {"properties": {}, "fromUuid": "c0e6049062be7b5abe626f2dba7ba087", "toUuid": "2963b6532a405451b63d6c17688029f5", "type": "EDGE_FILE_AFFECTS_EVENT", "timestamp": 1472571749998870}, "CDMVersion": "13"}
{"datum": {"properties": {}, "fromUuid": "2963b6532a405451b63d6c17688029f5", "toUuid": "5c1274b56ec811e693e844a8421f8dc6", "type": "EDGE_EVENT_ISGENERATEDBY_SUBJECT", "timestamp": 1472571749998870}, "CDMVersion": "13"}
{"datum": {"properties": {"cmdline": "-bash", "subjprocuuid": "5c1274b56ec811e693e844a8421f8dc6", "exec": "sshd", "arg_objuuid1": "142d3f01803f0351bf809481b103bfc8", "upath1": "/usr/local/bin/bash", "call": "aue_execve", "retval": "0"}, "uuid": "6336246134a6559fa57cdf91b3184cb7", "timestampMicros": 1472571750007870, "threadId": 100075, "type": "EVENT_EXECUTE", "source": "SOURCE_FREEBSD_DTRACE_CADETS", "sequence": 5}, "CDMVersion": "13"}
{"datum": {"isPipe": false, "properties": {}, "version": 1, "uuid": "142d3f01803f0351bf809481b103bfc8", "url": "/usr/local/bin/bash", "baseObject": {"properties": {}, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}}, "CDMVersion": "13"}
{"datum": {"properties": {}, "fromUuid": "142d3f01803f0351bf809481b103bfc8", "toUuid": "6336246134a6559fa57cdf91b3184cb7", "type": "EDGE_FILE_AFFECTS_EVENT", "timestamp": 1472571750007870}, "CDMVersion": "13"}
{"datum": {"properties": {}, "fromUuid": "6336246134a6559fa57cdf91b3184cb7", "toUuid": "5c1274b56ec811e693e844a8421f8dc6", "type": "EDGE_EVENT_ISGENERATEDBY_SUBJECT", "timestamp": 1472571750007870}, "CDMVersion": "13"}
{"datum": {"properties": {}, "fromUuid": "5c1274b56ec811e693e844a8421f8dc6", "toUuid": "a0641a9b43305c75aa889c78da0a0a36", "type": "EDGE_SUBJECT_HASLOCALPRINCIPAL", "timestamp": 1472571750007870}, "CDMVersion": "13"}
{"datum": {"properties": {"subjprocuuid": "5c1274b56ec811e693e844a8421f8dc6", "exec": "bash", "arg_objuuid1": "c0e6049062be7b5abe626f2dba7ba087", "fd": "0", "retval": "1", "fdpath": "/dev/tty", "call": "aue_read"}, "uuid": "2164220f8c555a0ebc7ce75a3fc5416f", "timestampMicros": 1472571751238024, "threadId": 100075, "type": "EVENT_READ", "source": "SOURCE_FREEBSD_DTRACE_CADETS", "sequence": 6}, "CDMVersion": "13"}
```

Another possibility is trying to isolate events in one of two ssh sessions.
Again, it is possible to track back the parent processes and use that, but that
is not the only option. While both will read and write from `/dev/tty`, the
uuids will be different, and sometimes the pseudo-terminal path will be given
instead of `/dev/tty`. 

```json
{"datum": {"url": "/dev/pts/1", "uuid": "c0e6049062be7b5abe626f2dba7ba087", "baseObject": {"properties": {}, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}, "properties": {}, "isPipe": false, "version": 1}, "CDMVersion": "13"}
{"datum": {"url": "/dev/tty", "uuid": "c0e6049062be7b5abe626f2dba7ba087", "baseObject": {"properties": {}, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}, "properties": {}, "isPipe": false, "version": -1}, "CDMVersion": "13"}
{"datum": {"url": "", "uuid": "c0e6049062be7b5abe626f2dba7ba087", "baseObject": {"properties": {}, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}, "properties": {}, "isPipe": false, "version": 2}, "CDMVersion": "13"}

{"datum": {"url": "/dev/pts/2", "uuid": "64ee4b938566e751a68583ede1e76e1a", "baseObject": {"properties": {}, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}, "properties": {}, "isPipe": false, "version": 1}, "CDMVersion": "13"}
{"datum": {"url": "/dev/tty", "uuid": "64ee4b938566e751a68583ede1e76e1a", "baseObject": {"properties": {}, "source": "SOURCE_FREEBSD_DTRACE_CADETS"}, "properties": {}, "isPipe": false, "version": -1}, "CDMVersion": "13"}
```

# Traces

Currently, we are sharing traces that instrument the following events:

* Filesystem events (e.g., open, close, dup, read, write)
* Process events (e.g., fork, exec, exit)
* Network events (e.g., connect, accept)
* SSH login events
* BuildInject scenario
