Initial CDM 14 Trace
====================

This shows a simplified version of what happens when `cat` is run, translated
by hand into the common format. The output has not been validated.

This is an incomplete translation.

Missing data (for now):
 * in FileObjects (all as of first recorded access)
   - owner
   - file permissions
   - size
 * in Events
   - name
   - parameters
   - programPoint
 * in Principals
   - groupIds


Data that will NOT be filled in
 * in FileObjects
   - fileDescriptor
   - peInfo
   - hashes
   - epoch
 * in Events
   - location
 * in Principals
   - username

There are also many other events yet to be translated.
