# Glossary

The terms, collected in one place, in
the plain words the guide uses for
them.

**Access token** — the bearer key a
login or registration hands a device.
Whoever presents it acts as that
user, on that device, until it is
revoked.

**Alias** — a room's human address,
`#hobby-club:lab.local`. The directory
resolves an alias to the room's true
ID. People share aliases; programs
use IDs.

**Client** — the app a person uses
(Element and its rivals). It logs in,
syncs, and sends on the user's
behalf, over the client-server API.

**Client-server API** — the published
set of web requests clients use. The
whole of chapter 4 is this API,
driven by `curl`.

**Device** — one login's worth of
presence: a phone, a browser, a
script. Each login mints a device ID,
and sessions can be ended per device.

**Event** — one entry in a room's
history: a message, a join, a
setting changed. Everything is an
event; events carry IDs beginning
with `$`.

**Federation** — servers exchanging
rooms' events directly, so users of
different servers share rooms. The
subject of chapter 7.

**Homeserver** — the program holding
accounts and rooms for its users.
Synapse is the one this guide runs.

**Join rule** — the state value
saying who may enter a room: `invite`
for the invited only, `public` for
anyone who can reach the room.

**Media store** — the folder where
uploaded files and their thumbnails
live as ordinary files, outside the
database.

**Power levels** — the table of
numbers that prices acts inside a
room. 0 talks and invites, 50 tends
and kicks, 100 rewrites the table
itself.

**Room** — a conversation: a shared,
signed history of events, copied to
every server with a member in it.
Rooms have IDs (`!…`) and usually an
alias.

**Room version** — the rulebook
edition a room was created under.
The lab's rooms are version 12,
whose IDs are opaque hashes and
whose creator's authority lives in
the create event.

**Server name** — the permanent
second half of every ID the server
mints, `lab.local` in the lab.
Chosen once; effectively unchangeable.

**Signing key** — the small private
file whose signatures let other
servers trust your server's events.
Guard it; back it up.

**Space** — a room whose members are
other rooms: a folder for organising
a community's rooms. Not exercised
in the lab; named here because
clients show spaces next to rooms.

**State event** — an event carrying a
room's current settings — name, join
rules, power levels. One per kind;
the latest is the truth.

**Sync** — the client's standing
question, "what is new for me?" —
and the server's streamed answer.
Chapter 12 records what the lab
learned about its freshness.

**UIAA** — user-interactive
authentication: the 401-and-session
dance that begins registration and
other sensitive acts, letting the
server ask for more than a password.
