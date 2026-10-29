# Troubleshooting

The traps this guide's lab actually
fell into come first — each with the
server's own words — followed by the
failures every operator meets. The
diagnosing order throughout is the
chapter's real lesson: ask the
server, believe the endpoints over
any summary, and read the log before
touching the config.

## Registration answered 401

That is the protocol working, not
failing. The first register post
returns 401 with a `session` and the
`flows` on offer (t03). Carry the
session into the second post and
complete the stage it names. If the
401 says registration is disabled
instead, the server has registration
closed — the default — and users are
added the admin way (recipe 1).

## "Invalid username or password" — but the password is right

The message is deliberately vague:
it covers no-such-user and
wrong-password alike, so the login
form cannot be used to fish for
valid names (t11). Check the user ID
spelling including the server part —
`@alice` is not `@alice:lab.local` —
and check *which* password: after
several logins, the token you want
may belong to an older device, but
passwords do not rotate on login.
The server log distinguishes the two
cases honestly; read it on the
server side rather than guessing
from the client side.

## "Too Many Requests" at login

You have met the rate limiter
(t13). Synapse counts failures — and
in the lab's case, attempts —
per address, and answers
`M_LIMIT_EXCEEDED` with a
`retry_after_ms` that means what it
says. Wait it out. If it recurs in
production, look for the one user
(it is usually one user, or one
household behind one address)
hammering retries, and only then
consider the `rc_login` settings in
the config.

## "User ID already taken"

`M_USER_IN_USE` (t11): the name
exists. On a small server this is
usually your own earlier success —
ask `whoami` with any token you hold
for it, or simply choose the name
you actually meant. There is no
takeover path, by design.

## The invite "never arrived" — and other sync disagreements

The lab's own trophy trap (t12).
One-shot sync answers disagreed —
with the room endpoints, and between
the bare and `full_state` flavours,
moments apart — while
`joined_rooms`, `joined_members` and
the member state agreed with each
other every time. A sync is a
snapshot that may lag the moving
present, especially a server's first
answers. Before concluding an invite
is lost: check the room's member
state directly, have the client
restart or refresh, and only then
suspect the invite itself. In the
lab, every "lost" invite was present
and correct in the state.

## A message comes back "not in room"

`M_FORBIDDEN`, "User … not in room …"
(t11). Two causes share the costume:
the room truly does not exist (the
lab aimed at a nonsense ID), or it
exists and the sender is not in it —
an invite never accepted, a room on
another server your user has not
joined. `joined_rooms` with the
sender's token separates the cases
at a glance.

## The admin recipe answers "HMAC incorrect"

The signed words matter to the byte.
On Synapse 1.164.1 the message ends
in `notadmin`, not the `user` that
older write-ups teach (t13) — the
lab proved both, against the server
and then in its source. Also check
the unglamorous causes: the secret
copied with stray quotes or spaces,
a nonce reused (they are one-shot),
and `admin` in the JSON not matching
the word you signed.

## It will not start

Read `homeserver.log` first — config
errors are reported there in plain
words, usually naming the offending
key. The recurring causes: a YAML
edit that broke indentation (the
config is one file; keep a copy
before editing), the port already
held by an earlier server you forgot
was running, and a data directory
the process cannot write. The
versions endpoint (chapter 3) is the
all-clear: when it answers, the
server is up, whatever the client
says.

## "It works at home but nobody can reach us"

The federation chapter's failure,
listed here for the searchers:
client works locally, outside users
never arrive. In documented order:
the `.well-known` discovery document
missing or pointing wrong, the
certificate untrusted, the
federation port or proxy path not
open, and — last, because it cannot
be fixed by trying harder — a
server name that was never public to
begin with, like the lab's
`lab.local`. The project's federation
tester exists for exactly this list;
this guide's lab could not run it,
because the lab's unreality is the
cause at the bottom of the list.
