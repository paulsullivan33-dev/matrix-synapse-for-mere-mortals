# Matrix (Synapse) for Mere Mortals

Most chat lives in someone else's
building. You get an account on a
company's server, your messages live
on its disks, and the address people
reach you at belongs to the company.
**Matrix** is the attempt to give chat
the shape email has: many independent
servers, run by many different people,
all able to talk to each other — and
you are allowed to run one of the
servers. **Synapse** is the server
program this guide installs: the
reference **homeserver**, the one the
protocol's own stewards maintain.

Running your own homeserver means the
accounts are yours, the rooms live on
your disk, and your address —
`@alice:example.org`, say — names
*your* server the way an email address
names yours. It also means the server
is only half the story. Nobody chats
with a server. People chat with a
**client** — an app like Element —
which talks to the server over a
published API. This guide keeps that
split in view the whole way, and its
lab proves the point by driving the
server with nothing but `curl`: every
thing the lab does by hand is a thing
your client will later do for you,
invisibly.

The lab behind this guide ran the real
thing: **Synapse 1.164.1**, installed
from PyPI into a Python virtual
environment, serving a server named
`lab.local` on loopback only, with
SQLite for its database and federation
switched off. Against it the lab
registered two users through the API —
including the two-step proof-of-human
dance registration starts with —
logged them in, created a room, sent
an invitation, watched it arrive in
the other user's sync, exchanged
messages both ways and read them back.
It changed who may join the room and
who counts as a moderator, and read
both settings back. It added a third
user the admin way, by shared secret,
with public registration closed. And
it broke things on purpose: wrong
passwords, a name already taken, a
message to a room that does not
exist, and a login rate limit tripped
by its own earlier mistakes.

What the lab could not do, it did not
fake. Federation — the whole point of
Matrix, and the riskiest part to open
up — needs a public name, public DNS
and a reachable port, none of which a
loopback lab can honestly provide;
chapter 7 teaches it from the
documentation and says so. Encryption
between clients, the look and feel of
the client apps, and running Synapse
in Docker or against PostgreSQL are
likewise labelled documented-only
wherever they appear. `criteria.md`
keeps the full ledger.

## What this guide covers

- [**What Matrix is**](what-matrix-is.md) —
  the network, the server name you can
  never change, and why the server is
  only half the story
- [**The moving parts**](the-moving-parts.md) —
  homeserver, clients, rooms, events,
  power levels and the signing key —
  and which part holds what
- [**Installing Synapse**](installing-synapse.md) —
  the Python install the lab ran, the
  generated config, and the two lines
  the lab changed in it
- [**Your first users**](your-first-users.md) —
  registration's two-step dance, the
  first logins, the first room, and
  messages read back through the API
- [**Rooms and permissions**](rooms-and-permissions.md) —
  join rules, power levels, and the
  moderator promotion the lab read
  back from the server
- [**Choosing a client**](choosing-a-client.md) —
  Element and its rivals, what a client
  actually does all day, and the
  encryption this guide does not fake
- [**Federation — opening the doors**](federation-and-opening-up.md) —
  what opening your server to the
  network means, what it needs, and
  what can never be taken back
- [**Media, retention and the database**](media-and-database-care.md) —
  where the files and the database
  live, why the database only grows,
  and the backups that are your server
- [**Recipes**](recipes.md) — add a
  user with registration closed, make
  a moderator, open and close a room's
  doors, and find a room by its alias
- [**The neighbours**](the-neighbours.md) —
  a hosted account on someone else's
  server, email, and the other
  messengers: what each does that
  Synapse doesn't, and vice versa
- [**Limits**](limits.md) — a server
  name that is forever, a database
  that only grows, copies you cannot
  recall, and keys that are yours to
  lose
- [**Troubleshooting**](troubleshooting.md) —
  the 401 that is not an error, the
  vague wrong-password message, the
  rate limit the lab tripped, and the
  sync that lags behind the truth
- [**Glossary**](glossary.md) — the
  terms, collected in one place

## What it doesn't cover

Running a public, federated server as
a going concern — moderation teams,
abuse reports, legal duties — is a
job, not a chapter; chapter 7 explains
what opening the doors involves so you
can decide with your eyes open, and
the operational depth beyond that
belongs to the project's own
documentation. Bridges to other
networks (Slack, IRC, WhatsApp and
friends), bots, and voice and video
calls are pointed at, not taught.
End-to-end encryption is explained
honestly in chapter 6 but was not
exercised in the lab, because two
`curl` scripts have no keys worth
protecting and nothing honest to
prove about them.

## How to use this guide

Read chapter 1 before choosing
anything: the server name decision
lives there, and it is the one
decision in this guide you cannot
undo. Chapters 2 and 3 get a server
running on your own machine; chapter
4 gives it people and a room, using
the same API your client will use.
Chapters 5 and 6 are the everyday
craft — permissions and clients.
Read chapter 7 twice before opening
a real server to the internet. The
lab's transcripts live in
`matrix-lab/transcripts/`; its driver
scripts are the `run-lab*.sh` files
beside them.

---

## Part of the series

This guide is one of the [For Mere Mortals](https://paulsullivan33-dev.github.io/mere-mortals/) guides: plain-language guides to the tools programmers and makers use.

Related guides:

- [Docker Compose for Mere Mortals](https://paulsullivan33-dev.github.io/docker-compose-for-mere-mortals/)
- [Caddy for Mere Mortals](https://paulsullivan33-dev.github.io/caddy-for-mere-mortals/)
- [PostgreSQL for Mere Mortals](https://paulsullivan33-dev.github.io/postgresql-for-mere-mortals/)
- [Backups for Mere Mortals](https://paulsullivan33-dev.github.io/backups-for-mere-mortals/)

## License

The writing in this guide is licensed under [CC BY 4.0](https://github.com/paulsullivan33-dev/matrix-synapse-for-mere-mortals/blob/main/LICENSE). Code examples and lab scripts are licensed under the [MIT License](https://github.com/paulsullivan33-dev/matrix-synapse-for-mere-mortals/blob/main/LICENSE-CODE).
