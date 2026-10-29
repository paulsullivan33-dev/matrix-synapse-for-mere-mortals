# The Moving Parts

By the end of this chapter you will be
able to name the parts of a Synapse
server — the config, the signing key,
the database, the media store, the
listeners — and say which part holds
what, so that later surprises arrive
as named problems instead of fog.

**Check:** the lab's own parts are
listed in
`matrix-lab/transcripts/t14-data-on-disk.txt`:
one database file of 2.2 MB, one
signing key of 59 bytes, one empty
media folder, after three users and
two rooms. If you can guess which of
those three is the server's identity
and which is its memory before
reading on, you are ahead.

## The config file

`homeserver.yaml` is the server's
whole personality in one text file:
its name, its listeners, its database,
and every switch the later chapters
touch. Synapse **generates** it for
you (chapter 3), with sensible
defaults and a few secrets minted on
the spot. You edit it by hand, and the
server reads it at startup; there is
no settings screen and no database of
settings hiding elsewhere. When a
behaviour puzzles you, the answer is
a line in this file or the lack of
one.

## The signing key

Next to the config sits a small file —
`lab.local.signing.key` in the lab,
59 bytes. It holds the private key
your server uses to **sign** the
events it sends to other servers.
Those signatures are how a stranger's
server knows an event really came
from yours. Lose this file and the
network stops trusting your server's
word; its users become unverifiable
to everyone else. It is, byte for
byte, the most important file the
server owns, and chapter 8 puts it at
the top of the backup list. Nobody
signs anything in the lab — there is
no one to federate with — but the key
is generated on day one regardless,
because the server's identity starts
then.

## The database

Everything the server knows — users,
rooms, events, who is in what — lives
in a **database**. Small servers use
**SQLite**, where the whole database
is one file (`homeserver.db`, with a
write-ahead log beside it while the
server runs). Busy servers use
PostgreSQL, a separate database
server; that route is documented-only
in this guide, and the PostgreSQL
guide in this series teaches the
database itself. The lab's 2.2 MB
SQLite file is the entire memory of a
three-user server: copy that file
(while the server is stopped, or with
its log) and you have copied the
server's past.

## The media store

Files people send — pictures, voice
notes, attachments — are not in the
database. They live as ordinary files
under a **media store** directory,
with the database remembering which
file is which. The lab sent only text,
so its media store stood empty
(t14); a real server's grows with
every photograph anyone posts, which
is why chapter 8 treats media and
retention together.

## The listeners

A Synapse server answers the web on
**listeners**: a port, a set of
addresses, and a list of jobs. The
generated config has one listener on
port 8008 doing two jobs — **client**
(the API your apps use) and
**federation** (the server-to-server
API). The lab edited its config to
remove the federation job, leaving a
server that can be talked *to* by its
own users' clients and by nothing
else (t01). In production the same
port usually sits behind a reverse
proxy — Caddy or nginx, both of which
have guides in this series — which
adds the HTTPS certificates browsers
insist on. The lab, loopback-only,
ran plain HTTP and said so.

## The parts that are not Synapse's

Two more pieces complete every real
deployment, and neither ships with
Synapse. A **client** for every user
(chapter 6) — the server alone gives
nobody a screen to type on. And, once
federation opens, the **name system**:
DNS records and certificates that let
other servers find yours by its name
(chapter 7). Hold those two absences
in mind and the architecture is
honest: Synapse is the middle of the
sandwich, not the sandwich.

**Check:** point at each file in
t14's listing and name its job —
config, key, database, media, log.
When you can also say which single
file you would rescue first from a
burning disk (the signing key can be
regenerated only at the cost of the
network's trust, so most operators
say the database *and* the key, in
that order of panic), chapter 3 can
start building.
