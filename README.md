# CADETS Trace Data

The current CADETS trace serialization format is an array of JSON
event objects. As the trace format is based on JSON, it will be simple to
write a translator to convert from the CADETS trace format to the CDM
format.

Here is an example CADETS trace event:

```json
[

  {
    "event": "syscall:freebsd:open:entry",
    "time": 1455713720382922000,
    "pid": 1188,
    "tid": 100606,
    "uid": 1001,
    "exec": "wget",
    "path": "index.html"
  },

]
```

Each event will have a subset of following attributes:

* _event_: Event name. We use DTrace's naming convention for events
  (<dtrace provider>:<module>:<function>:<probe name>). For example,
  "syscall:freebsd:open:entry" is an event that is triggered when the
  FreeBSD ```open()`` system call is entered.
* _time_: The time the event occurred expressed as nanoseconds since 00:00
  Universal Coordinated Time, January 1, 1970.
* _pid_: The ID of the process that generated the event.
* _ppid_: The ID of the parent of the process that generated the
  event.
* _tid_: The ID of the thread that generated the event.
* _uid_: The ID of the user that generated the event.
* _exec_: The name of the executable associated with this event.
* _args_: The command-line arguments for an executable's invocation.
* _path_: The filesystem path associated with this event.
* _fd_: The filesystem descriptor (fd) associated with this event.
* _address_: The IPv4/v6 address associated with an event.
* _port_: The network port associated with an event.

Specific applications may have extra attributes:

* _query_: The database query associated with the event (for Postgresql)
* _request_: The HTTP request associated with the event (for nginx)

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

In the future, we will include traces that provide:

* More system-level events (e.g., filesystem events)
* Function-level tracing for kernel subsystems of interest
* Temporal automata events
* LOOM compiler instrumentation events
* Information flows
* Multi-node events
