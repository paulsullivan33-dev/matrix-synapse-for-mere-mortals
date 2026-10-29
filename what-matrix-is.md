# What Matrix Is

By the end of this chapter you will be
able to say what Matrix is, what a
homeserver does, and which decision —
made in the first five minutes — you
will live with for the life of your
server.

**Check:** if you can finish the
sentence "an address like
`@alice:example.org` tells you …" you
have the chapter. The answer: which
server alice's account lives on, the
way an email address names a mail
server.

## A network, not an app

Matrix is an open **protocol** — a
published set of rules for how chat
servers and chat programs talk to each
other — wrapped in a **network** of
independent servers that follow those
rules. There is no single Matrix
company holding everyone's messages.
matrix.org runs the biggest server,
but it is one server among thousands,
and it holds no special key.

That shape should sound familiar. It
is the shape of email, and of the web:
anyone may run a server, the servers
interoperate, and leaving one server
for another does not exile you from
the conversation. The modern chat
giants chose the opposite shape — one
company, one server, everyone's
account — and Matrix exists because
some people wanted the older bargain
back.

## The server is half the story

A **homeserver** is the program that
holds accounts and rooms for its
users. **Synapse** is the homeserver
this guide installs — the reference
implementation, written in Python,
maintained by the people who steward
the protocol. It is not the only one,
but it is the one new server owners
meet first, and the one the
documentation assumes.

Nobody talks to a homeserver directly.
People use a **client** — Element is
the best-known; chapter 6 meets the
others — and the client does the
talking, over the **client-server
API**: a set of web requests any
program may make. This guide's lab
makes those requests with `curl`, on
purpose. When you have seen a login, a
room and a message as plain requests
and replies, no client can ever be
magic to you again — it is buttons on
top of exactly those requests.

## Rooms are where it happens

Conversation lives in **rooms**. A
room is not a file on one server; it
is a shared history that every
participating server keeps a copy of,
built one **event** at a time. A
message is an event. So is joining,
leaving, changing the room's name, or
promoting a moderator — everything
that happens in a room is an event in
its history, signed by the server it
came from. Chapter 2 takes the event
model apart; for now, hold onto this:
a room's history is the room, and
every server in the room holds a copy.

A room can live on one server (two of
your own users, talking) or span fifty
(a public room whose members' servers
all replicate it). The lab's rooms
live on one server only, because the
lab's server talks to nobody else —
which brings us to the doors.

## Federation: servers talking to servers

When users from different servers
share a room, the servers exchange
the room's events directly, server to
server. That is **federation**, and it
is what makes Matrix a network rather
than a pile of private chat servers.
It is also a commitment. A federated
room's history exists on other
people's disks, beyond your power to
delete; strangers' servers connect to
yours; and your users can wander into
rooms you would never have chosen.
Chapter 7 is devoted to opening those
doors deliberately. The lab keeps
them shut: its server has the
federation listener switched off and
a name nobody could reach anyway.

## The name you cannot change

Every account ID ends with the
server's name: `@alice:lab.local`.
Every room alias carries it too:
`#hobby-club:lab.local`. The **server
name** is not a label you can repaint
later; it is baked into every ID the
server will ever mint, and the rest
of the network knows your users by
those IDs. Rename the server and you
have not renamed anything — you have
started a new server whose users are
strangers to the old one's rooms.

So the first decision of any real
install is the name, and it deserves
five quiet minutes. It is usually a
domain you own — `example.org`, with
accounts like `@alice:example.org` —
because federation will later need
the world to find that name. The lab
uses `lab.local`, a name that exists
only inside the lab, precisely
because the lab must never be
reachable: it is the honest choice
for a server that will be deleted
when the experimenting is done, and
chapter 3 says so again where the
name is typed.

**Check:** say the three parts of
`@bob:lab.local` out loud — the user
(bob), and the server that vouches
for him (lab.local). If you can also
say why bob cannot become
`@bob:otherplace.org` without a new
account, this chapter has done its
work, and chapter 2 can show you the
machine room.
