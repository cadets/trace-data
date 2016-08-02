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
	"subjuuid": "b5b79f21-4ea7-11e6-ab31-44a842348b1c",
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
  {"event": "audit:event:aue_unlink:", "time": 1469212266719943874, "pid": 3555, "ppid": 3554, "tid": 100153, "uid": 0, "exec": "remove_file", "subjuuid": "73bc6807-503a-11e6-b8c7-080027889132", "arg_objuuid1": "ea7eea24-097f-cf5b-bf09-a3843bcf40b6", "upath1": "/usr/home/strnad/unit_tests/temp.out", "retval": 0}
, {"event": "audit:event:aue_exit:", "time": 1469212266719943874, "pid": 3555, "ppid": 3554, "tid": 100153, "uid": 0, "exec": "remove_file", "subjuuid": "73bc6807-503a-11e6-b8c7-080027889132", "retval": 0}
]
```

In CDM format, it looks like this
[remove_file.json.CDM.json](./unit_test_traces/remove_file.json.CDM.json). This
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
{"datum": {"timestampMicros": 1469212271398110, "uuid": "00000000000000030000000000000019", "sequence": 25, "source": "SOURCE_FREEBSD_DTRACE_CADETS", "threadId": 100259, "type": "EVENT_EXECUTE", "properties": {"subjuuid": "76dd6962-503a-11e6-b8c7-080027889132", "arg_objuuid1": "c63c9e57-55b6-7d59-b655-e198f97d106e", "probe": "", "module": "event", "call": "aue_execve", "provider": "audit", "path": "/usr/local/bin/wget", "retval": "0", "upath1": "/usr/local/bin/wget"}}, "CDMVersion": "13"}
{"CDMVersion": "13", "datum": {"baseObject": {"source": "SOURCE_FREEBSD_DTRACE_CADETS", "properties": {}}, "uuid": "000000000000000649883dfd38c0a873", "url": "/usr/local/bin/wget", "isPipe": false, "version": 1, "properties": {}}}
{"CDMVersion": "13", "datum": {"fromUuid": "000000000000000649883dfd38c0a873", "toUuid": "00000000000000030000000000000019", "properties": {}, "timestamp": 1469212271398110, "type": "EDGE_FILE_AFFECTS_EVENT"}}
```

# Traces

The current traces we are sharing include:

* [Wget](./wget_google.json) - Trace of "wget google.com"
* [Git server](./git_server.json) - Trace of git session over SSH
* [Postgres](./postgres.json) - Partial trace of pgbench events
* [Nginx](./nginx.json) - Trace of nginx handling http request
  (limited to only nginx function events)
* [Nginx plus all library function calls](./nginx_with_libs.json) -
  Trace of nginx handling http request (including all external library
  calls)

Currently, we are sharing traces that instrument the following events:

* Filesystem events (e.g., open, close, dup, read, write)
* Process events (e.g., fork, exec, exit)
* Network events (e.g., connect, accept)
* User-space function call entry/return
* Nginx http request events
* Postgresql query events
* Git events (e.g., receive-pack, upload-pack)
* SSH login events
* BuildInject scenario
