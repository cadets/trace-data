Details of CADETS CDM Mapping
=============================

The CADETS system tracks events. Events are converted to CDM events one at a
time, maintaining minimal state. Related objects are created when they are
first seen in the CADETS trace, and filled in as well as possible. If CADETS
does not trace the creation of the object, it may not be able to provide
information about all object attributes.

Syscalls to CDM Events
----------------------

All events will create the following related objects if not already defined:
PROCESS_SUBJECT, PRINCIPAL_LOCAL

predicateObjectPath, when provided, is always related to predicateObject.
Likewise, predicateObject2Path, when provided, is always related to
predicateObject2 (except in the case of link, where both paths related to
predicateObject).

Types given in the table below are generally accurate, but exceptions apply.
For example, while close is normally used on files, it can also be used on
processes (see
[`man 2 pdfork`](https://www.freebsd.org/cgi/man.cgi?query=pdfork&sektion=2&manpath=FreeBSD+11.0-stable)).

Any syscall not in this list will be EVENT_OTHER. The name of the syscall will
be available as the event `name`.

syscall    | Event type (EVENT_...) | Parameters      | Related objects
-----------|------------------------|-----------------|----------------
execve*    | EXECUTE                |                 | PO (executable), PO2 (loader)
accept*    | ACCEPT                 |                 | PO (socket), PO2 (socket)
bind*      | BIND                   |                 | PO (socket)
close*     | CLOSE                  |                 | PO (closed object)
lseek*     | LSEEK                  |                 | PO (file)
connect*   | CONNECT                |                 | PO (socket)
fchdir*    | MODIFY_PROCESS         |                 | PO (dir)
chdir*     | MODIFY_PROCESS         |                 | PO (dir)
umask*     | MODIFY_PROCESS         |                 | PO (process)
exit*      | EXIT                   |                 |
fork*      | FORK                   |                 | PO (new process)
pdfork*    | FORK                   |                 | PO (new process)
setuid*    | CHANGE_PRINCIPAL       | uid             |
setgid*    | CHANGE_PRINCIPAL       | gid             |
seteuid*   | CHANGE_PRINCIPAL       | euid            |
setegid*   | CHANGE_PRINCIPAL       | egid            |
setreuid*  | CHANGE_PRINCIPAL       | uid, euid       |
setregid*  | CHANGE_PRINCIPAL       | gid, egid       |
setresgid* | CHANGE_PRINCIPAL       | gid, egid, sgid |
setresuid* | CHANGE_PRINCIPAL       | uid, euid, suid |
fcntl*     | FNCTL                  | fcntl_cmd       | PO (file)
chmod*     | MODIFY_FILE_ATTRIBUTES | mode            | PO (file)
fchmod     | MODIFY_FILE_ATTRIBUTES | mode            | PO (file)
fchmodat   | MODIFY_FILE_ATTRIBUTES | mode, flag      | PO (file)
lchmod*    | MODIFY_FILE_ATTRIBUTES | mode            | PO (file)
chown*     | MODIFY_FILE_ATTRIBUTES | uid, gid        | PO (file)
fchown*    | MODIFY_FILE_ATTRIBUTES | uid, gid        | PO (file)
lchown*    | MODIFY_FILE_ATTRIBUTES | uid, gid        | PO (file)
futimes*   | MODIFY_FILE_ATTRIBUTES |                 | PO (file)
lutimes*   | MODIFY_FILE_ATTRIBUTES |                 | PO (file)
utimes*    | MODIFY_FILE_ATTRIBUTES |                 | PO (file)
link*      | LINK                   |                 | PO (file), PO2 (path only)
unlink*    | UNLINK                 |                 | PO (file)
mmap*      | MMAP                   |                 | PO (file)
mkdir*     | CREATE_OBJECT          |                 | PO (dir)
rmdir*     | UNLINK                 |                 | PO (dir)
mprotect*  | MPROTECT               |                 | PO (file)
open*      | OPEN                   | flags, mode     | PO (file)
pipe*      | CREATE_OBJECT          |                 | PO (one end of pipe), PO2 (other end)
read*      | READ                   |                 | PO (file)
pread*     | READ                   |                 | PO (file)
write*     | WRITE                  |                 | PO (file)
pwrite*    | WRITE                  |                 | PO (file)
rename*    | RENAME                 |                 | PO (initial file), PO2 (new path)
sendto*    | SENDTO                 |                 | PO (socket)
sendmsg*   | SENDMSG                |                 | PO (socket)
symlink*   | CREATE_OBJECT          |                 | PO (file)
recvfrom*  | RECVFROM               |                 | PO (socket)
recvmsg*   | RECVMSG                |                 | PO (socket)
pdkill*    | SIGNAL                 | pid, signum     | PO (process)
kill*      | SIGNAL                 | pid, signum     | PO (process)
truncate*  | TRUNCATE               |                 | PO (file)
ftruncate* | TRUNCATE               |                 | PO (file)
wait*      | WAIT                   |                 |
setlogin*  | LOGIN                  |                 |
shm*       | SHM                    |                 |
socket     | CREATE_OBJECT          |                 | PO (socket)
socketpair | CREATE_OBJECT          |                 | PO (socket), PO2 (socket)

Key:

- PO - predicateObject
- PO2 - predicateObject2

Files
-----

The CADETS system provides uuids for many kernel-managed objects. CADETS
uuids are reliable, kernel-managed identifiers.

In the case of files, note that it is possible for two different paths to refer
to the same uuid - these are still the same file. Either both paths point to
the same location on the underlying file system, or the path has changed. It is
also possible to have two separate uuids for the same path. This can happen
when a file is deleted and a new file with the same name is created.

Event Information
-------------------

Each event in CADETS is reported in the order it is received from the system.
This means events can occasionally be transmitted out of order. The sequence
number is not an absolute indicator of order, though within a thread it would
be accurate.

The `threadId` reported by CADETS does refer to the thread id. The pid is
located in the Event's `subject` as the `cid`.

There is one type of event for which CADETS does not create an object for the
related UUIDs. CADETS includes semaphore related events in the traces.
Semaphores have UUIDs in the CADETS system. This will only be seen on
EVENT_OTHERs, on semaphore related events.

Some events, particularly ones that change the current user or group, will
include parameters to detail the event's arguments. All parameters will have a
name and, unless isNull is true, the valueBytes will be set. At the moment,
CADETS only sends parameters of type INT.

Subject Information
-------------------

Each subject in CADETS represents a process. Each process is reported as soon
as it appears in the CADETS trace.  Ideally, subjects are reported upon
creation, but sometimes may be reported at a later point in their lifecycle.
This is most likely because the process was already running when tracing began.

A fully filled in subject for CADETS will have the process UUID, the parent
process UUID, the type as SUBJECT_PROCESS, the pid (in the cid field), the
current principal, and the start time.  If the subject is created later in its
lifecycle, the start time will be 0, and no parent process will be given.

Principals
----------

CADETS does not provide information in the Principal object beyond the userId.
Principal related events will provide more information about the principal
within the event. For example, the login event will usually include the
username of the user logging in.

Pipe Endpoints
--------------

Unnamed pipes' endpoints are represented using the SrcSinkObject. This type is
used because each endpoint has its own UUID.

Properties
----------

Here is a subset of possible properties:

- ret_metaio - indicates source object uuid in a flow
- arg_metaio - indicates sink object uuid in a flow
- ret_msgid - a number identifying a message sent or recieved. Can be
  used to link IPCs (e.g., linking sendto and recvfrom)
- login - name of user logging in
- ppid - process id of parent process (not a UUID)
- address - address used by event, usually an ip address
- port - port used by event
- cmdLine - command line used when executing a program
- fd - file descriptor used by the event
- return_value - return value of the syscall

Not Used
--------

There are many types within the CDM that CADETS does not use. We do not use
CryptographicHash, TagRunLengthTuple, ProvenanceTagNode, UnitDependency,
RegistryKeyObject, or UnnamedPipeObject.

In general, CADETS does not produce TimeMarkers, though we can if requested.
This is only a temporary feature.
