# The Neighbours

Matrix with Synapse is one answer to
"how do my people talk?" — and not
the only shape of one. This chapter
walks the fence line: what each
neighbour does that this stack
doesn't, and vice versa. The
neighbours are characterised, not
run; the chapter is documented-only
except where it leans on the lab's
own evidence about what a homeserver
is.

## A hosted account — the same network, no server

The neighbour most people should
meet first is Matrix itself without
Synapse: an account on matrix.org, or
on any public homeserver, taken in
five minutes in a client. Same
rooms, same addresses, same
federation — somebody else patches,
backs up, moderates the plumbing and
pays for disks. What you give up is
exactly what this guide exists to
keep: the accounts are theirs, the
data sits with them, and a hosted
server's closure is your eviction
notice. Half the honest answer to
"should I run Synapse?" is "not
until a hosted account chafes in a
specific way you can name."

## Email — the older federation

Email is Matrix's ancestor in shape:
federated servers, addresses that
name a domain, no central owner. It
is also a standing lesson in what
federation does over decades —
interoperability that genuinely
works, wrapped in spam economics, a
few giant operators most people
default to, and deliverability as a
dark art. Choose email for reaching
everyone on earth asynchronously.
Choose Matrix for rooms that feel
like conversation rather than
correspondence — and take email's
history as chapter 7's quiet
footnote: build the small server
well, because small servers are the
point of a federation, even when
giants grow beside them.

## The walled messengers

Signal, WhatsApp, Telegram and
their kin are the neighbours with
the best paint. Their encryption is
strong, their apps are polished,
their onboarding takes a phone
number and thirty seconds. What they
do not offer is a server: there is
no address of your own, no room that
exists on your disk, no leaving
without leaving everyone. For most
people, most days, that trade is
fine — and this guide's position is
that it should be a *trade*,
knowingly made, rather than the
only imaginable shape of chat.

## The machine messengers in this series

Two series neighbours talk constantly
and are not for people at all, which
is its own clarification.
[MQTT for Mere Mortals](https://paulsullivan33-dev.github.io/mqtt-for-mere-mortals/)
moves small messages between devices
through a broker — sensors and
switches, not conversations.
[Ntfy for Mere Mortals](https://paulsullivan33-dev.github.io/ntfy-for-mere-mortals/)
sends one-way notifications to a
phone with a single web request —
alerts, not rooms. And
[Meshtastic for Mere Mortals](https://paulsullivan33-dev.github.io/meshtastic-for-mere-mortals/)
is the people-messenger that leaves
the internet out entirely, passing
texts between pocket radios on a
mesh. Reach for Matrix when the
conversation is among people, in
rooms, on infrastructure you may
choose; reach for these when the
talker is a thermostat, a cron job,
or a hilltop with no signal.

**Check:** name the neighbour whose
terms you would accept for a family
chat, a public hobby room, and a
server-room alert — hosted Matrix,
Synapse, and ntfy are defensible
answers, in that order. If each
choice came with its reason, the
fence line is where it should be.
