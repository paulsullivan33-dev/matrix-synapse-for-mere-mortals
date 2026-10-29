# Media, Retention and the Database

By the end of this chapter you will
know where your server's growing
weight actually sits — the media
store and the database — why both
only grow unless you act, and what a
backup must contain before you may
call it one. The sizes quoted are
the lab's, measured in t14; the
policies for large servers are
documented-only and labelled.

**Check:** after reading, you should
be able to answer the only backup
question that matters: "if this disk
died tonight, which files, copied
while the server was in what state,
would bring my server back — name,
keys, rooms and all?" The answer is
assembled at the chapter's end.

## Two piles, growing differently

Recall chapter 2's split. **Media**
— every image, file and voice note
anyone sends — lands as files in the
media store. **Everything else** —
accounts, rooms, and above all the
*events*: every message and state
change a room has ever had — lands
in the database. The lab, with three
users exchanging two text messages,
ended with a database of 2.2 MB and
an empty media store (t14): a text
room is nearly free, and its cost
sits in the database. A photo-heavy
room inverts the picture entirely.
Know which pile your server's life
fills, because they are pruned with
different tools and feared in
different ways.

## Why the database only grows

A Matrix room is its history, and a
server in a room keeps the history —
not just the messages but the *state
at every step*, which federation
needs to prove the room's past to
newcomers. Busy public rooms
accumulate state ferociously, and
Synapse's honest default is to keep
everything forever: deletion of a
message redacts its content but the
event's skeleton stays, because the
room's shared maths depends on it.
Old, large servers measure their
databases in tens or hundreds of
gigabytes, and the growth is mostly
rooms the operator forgot they were
in.

The levers that exist, all
documented-only here because the
lab's database would fit on a
floppy-era joke: Synapse can **purge
** a room's history from your server
(an admin act, appropriate for rooms
your users have left or rooms that
should never have been joined), it
runs periodic **state compression**
internally, and its configuration
carries retention settings that bound
how long some classes of data are
kept. The operational lesson that
survives every version of the tools:
leave rooms you do not need, think
twice before joining a homeserver
of yours to enormous public rooms,
and watch the database's size on a
schedule, not in a panic.

## Media and its own retention

Media has the mirror-image problem.
The store keeps what was sent,
including thumbnails Synapse makes
for previews, and — the sharp edge —
**remote** media: when your user
views an image posted from another
server, yours fetches and caches a
copy, and a busy server's cache of
other people's pictures can dwarf
its own users' uploads. Synapse's
configuration can expire remote
media after a chosen age and cap
upload sizes; those settings are
documented-only in this guide (the
lab's store stayed empty), but their
existence is the point to carry
away: on a real server, set the
remote-media lifetime on day one,
because "keep everything forever"
is a decision too — the default one,
taken silently.

## SQLite, and when to leave it

The lab's one-file database deserves
its good name for small servers: no
separate database to run, backups by
copying, and honest performance for
a household or a club. Its costs are
structural — one writer at a time,
and every one of Synapse's workers
queueing at the same door — and a
server that grows past a handful of
active users, or joins busy
federated rooms, feels them. The
documented migration path to
PostgreSQL exists and is the
standard advice for a server that
has outgrown SQLite; the PostgreSQL
guide in this series teaches the
database itself. The decision rule
is simple to state: SQLite while the
server is yours-and-a-few, honestly
measured; PostgreSQL before it
becomes yours-and-a-public.

## The backup that is one

A backup of a Synapse server is
four things, all named in earlier
chapters and collected here: the
**config** (`homeserver.yaml`), the
**signing key** (without it, the
restored server is a stranger
wearing your name), the **database**,
and the **media store**. The
database must be copied in a state
it agrees with — server stopped, or
a copy taken the database's own way
(SQLite's online backup, PostgreSQL's
dump tools); a file copied raw from
under a running server, write-ahead
log and all, may restore to a
surprise. And the standing rule of
the Backups guide in this series
applies with full force: a backup
you have never restored is a hope,
not a backup. Restore yours onto a
spare folder once, start it, and log
in, before you need it for real.

**Check:** name the four parts of
the backup, and for the database,
name the trap (copied raw, mid-run,
with its log left behind). If your
server matters, you now also know
the two numbers to watch monthly:
the database's size and the media
store's. Chapter 9 turns this
chapter's knowledge into standing
routines.
