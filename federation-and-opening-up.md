# Federation — Opening the Doors

By the end of this chapter you will
know what federation actually does
with your rooms, what a server needs
before the network can reach it, and
which consequences of opening up
cannot be undone. Read it as a
briefing, not a procedure: **the lab
never federated.** Its server had
the federation listener removed and
a name (`lab.local`) that exists
nowhere in public DNS, on purpose.
Everything in this chapter is taught
from the project's documentation and
the protocol's design, and it is
labelled documented-only in
`criteria.md` — because a loopback
lab that claimed to test federation
would be lying to you, and the
honest version of this chapter is
the useful one anyway: federation is
mostly *decisions*, and decisions
can be taught without a switch being
thrown.

**Check:** the check is a question
you should be able to answer for
your own server before opening it —
"if a stranger's user joins my
public room tonight, what copies of
what will exist on whose disks
tomorrow?" The chapter gives you the
answer; make sure you can give it
back.

## What federation does

When bob of `example.org` joins a
room hosted by alice of
`example.net`, the two servers open
a conversation of their own. Each
sends the other every event its
users add to the room, signed with
its signing key (chapter 2's small,
crucial file), and each stores the
room's whole history. The room does
not live "on" alice's server in any
exclusive sense from that moment: it
lives on every server with a user in
it, kept in step by the servers
exchanging events. That is the
network's great strength — no single
server's failure or misbehaviour can
kill a room — and it is the source
of every consequence below.

## What a server needs to be reached

Four things stand between a private
Synapse and the network, and each is
a place real installs go wrong.

**A public, permanent name.** The
server name from chapter 1 must be a
domain you control and intend to
keep — every account ID carries it
forever. Many operators name the
server after a domain they already
own and delegate the traffic to a
subdomain where Synapse actually
lives.

**Discovery.** Other servers find
yours by looking your name up: a
`.well-known` document served over
HTTPS at your domain, pointing to
the address and port where Synapse
listens for federation (8448 by
convention, or the standard HTTPS
port through a reverse proxy).
Clients use a sibling document to
find the client API. This is the
step whose failure produces the
classic symptom: "my users can talk
to each other, but nobody outside
can reach us."

**Certificates.** Federation and
client traffic both demand HTTPS
with a certificate other servers
trust — in practice, a public
certificate authority's certificate,
of the kind Caddy (which has a guide
in this series) fetches
automatically when it stands in
front of Synapse as a reverse proxy.

**The federation listener, back
on.** The line the lab deleted —
`federation` in the listener's
resources — returns, and with it the
server's willingness to speak to
strangers. There are finer controls
(allowlists of servers, for a
deliberately small federation), and
they exist in the documentation;
know that "federated with everyone"
and "federated with nobody" are not
the only two positions.

## What can never be taken back

Open the doors with these four facts
in view, because each is one-way.

**Copies outlive your wishes.** A
federated room's history — messages,
media, membership — sits on every
participating server's disks. You
can delete your copy. You cannot
delete theirs, and a server run by
someone careless or hostile keeps
what it was given. Post in federated
rooms as if the room were being
archived by strangers, because it
is, by design, with everyone's
consent but no one's recall button.

**Your server becomes reachable —
by everyone.** The network includes
the badly run and the badly
intentioned. Public rooms attract
spam and worse; running a federated
server with public rooms is, in
part, a moderation job, with tools
(dedicated moderation bots and
blocklists exist) and with time
attached. A closed-registration
server with invite-only rooms —
the shape this guide's lab ends in —
takes a fraction of that weather,
and for a household or a club it is
often the right final position, not
a timid half-measure.

**Your users can leave without
leaving you.** Federation means your
people can join rooms on servers
whose rules you would never set.
Their client shows one list of
rooms; the jurisdictions behind it
are many. That is the freedom the
protocol exists to provide, and it
is also why "I run the server" never
means "I control what my users
see."

**The name is the server.** Repeat
chapter 1 one last time, because
federation is where it bites: once
other servers know your users, the
name is load-bearing. Choose it
like a tattoo.

## A sane order of operations

For a real server, the path most
operators walk is: private first
(this guide's lab, on a real name,
registration closed, invite-only
rooms, family or club happily
talking). Then discovery and
certificates, tested with the
project's own federation tester.
Then one public room, watched.
Federation is a dial with many
settings and a ratchet on some of
them; turn it slowly, and read
chapter 8 before your first month
is out, because a federated server's
database grows with every room it
touches.

**Check:** list the four
requirements — public name,
discovery, certificates, the
listener restored — and the four
one-way facts, from memory. If you
can, you are ready to decide about
opening up, which is the only thing
this chapter ever promised.
