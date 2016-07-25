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
* _subjuuid_: A UUID of the process that generated the event.
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
