# Limits

The honest edges of the thing,
collected in one place. Some of these
are Synapse's, some are Matrix's
design showing through, and one is
the lab's own boundary. None of them
is a reason to walk away; all of
them are reasons to walk in with
your eyes open.

**The name is forever.** Chapter 1's
point, listed here because it is the
limit owners feel most. The server
name is inside every user ID and
room alias ever minted. Plan to keep
the domain, or plan to start over
someday as a stranger.

**The database only grows.** Rooms
keep their history and their state;
the defaults keep everything
(chapter 8). A server's appetite is
a function of the rooms it touches,
and the largest public rooms are
genuinely enormous. SQLite suits the
small end; growth past it is a
migration, not a setting.

**Copies are not yours to recall.**
In federated rooms, your events live
on other servers from the moment
they are sent (chapter 7). Deleting
your copy is housekeeping, not
erasure. Anything unsayable-if-leaked
is unsayable in a federated room,
and encrypted rooms narrow — but do
not close — the question of who can
read content; membership and timing
remain visible to the servers
involved.

**Keys are the users' problem.**
End-to-end encryption puts recovery
in the device owners' hands (chapter
7). There is no admin master key and
no password reset for a lost
encryption history. On your own
server you can reset an account's
login password; you cannot give its
owner back their encrypted past, and
anyone who promises otherwise is
selling something.

**One server is one point of
failure.** Your users' rooms on
other servers survive your outage;
their accounts do not. When your
server is down, your people are
offline, and the backup in chapter 8
is the whole of the disaster plan.

**Synapse is the heavyweight.**
It is a large Python application
with a large appetite, happiest
behind a reverse proxy, with worker
processes and PostgreSQL at sizes
this guide deliberately does not
reach. Other homeserver
implementations exist and are
lighter; Synapse is the reference,
not the featherweight, and this
guide chose it for its documentation
and its honesty about its own state,
not for its footprint.

**Rate limits are real and
per-address.** The lab tripped the
login limiter with its own mistakes
(t13): enough failed logins from one
address and even the right password
waits. Behind one household or
office address, a determined
forgetter can briefly lock the
doorstep for everyone — tunable in
the config, and worth knowing
before it pages you.

**This guide's own limits.** The lab
ran one server, three users, two
rooms, no federation, no encryption,
no media, no clients on screens.
Claims beyond that fence are labelled
documented-only where they stand,
and `criteria.md` holds the ledger.
A guide that tells you exactly where
its evidence ends is worth more than
one that gestures at the horizon —
including this one, so the fence is
drawn where the transcripts stop.
