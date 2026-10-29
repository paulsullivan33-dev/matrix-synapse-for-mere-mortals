# Your First Users

By the end of this chapter your server
will have two people on it. They will
have registered through the API —
meeting its two-step dance honestly —
logged in, built a room, exchanged an
invitation, talked both ways, and read
the conversation back. Everything is
done with `curl`, because everything
a client app does is these requests
with better manners.

**Check:** the chapter's evidence is
that bob can fetch the room's history
and see both messages, alice's and
his own, in the order they were sent
(t08). When your run can do that,
the server works.

## Registration is a conversation

Posting a username and password to
`/_matrix/client/v3/register` does
not, by itself, register anyone. The
lab's first post sent an empty body
on purpose, to see what the server
asks for (t03):

```text
HTTP 401
{"session":"TQJRVSjHcSGnLXQOCuKLbEks",
 "flows":[{"stages":["m.login.dummy"]}],
 "params":{}}
```

That 401 is not a failure; it is the
protocol introducing itself. This
back-and-forth is called **UIAA** —
user-interactive authentication — and
it exists because servers may demand
proof beyond a password: a captcha, an
email round-trip, a token. The server
names the **flows** it accepts, each a
list of **stages**, and hands you a
**session** string to carry through
them. The lab's server, told to allow
registration without verification
(chapter 3), offers one flow with one
stage: `m.login.dummy`, the stage that
asks for nothing. Completing it is a
second post, carrying the session:

```bash
curl -s -X POST .../_matrix/client/v3/register \
  -d '{"username":"alice",
       "password":"AlicePass!234",
       "auth":{"type":"m.login.dummy",
               "session":"<the session from step 1>"}}'
```

The answer names the new citizen —
`@alice:lab.local` — and includes an
**access token** and a **device ID**:
registration logs you in as it creates
you. Bob registered the same way
(t04). The lab's passwords
(`AlicePass!234`, `BobPass!345`) are
throwaways for a server that will be
deleted, and the transcripts say so;
yours should be neither published nor
reused.

Two honest notes. First, a real
server with verification switched on
adds stages to that flow — the dance
has more steps, but the shape is the
one you just saw. Second, registering
a name that is taken fails with
`M_USER_IN_USE` (t11) — the server
will not silently hand you someone
else's identity.

## Logging in is a device being born

Registration's token works, but the
ordinary way in is the login call
(t04):

```bash
curl -s -X POST .../_matrix/client/v3/login \
  -d '{"type":"m.login.password",
       "identifier":{"type":"m.id.user",
                     "user":"@alice:lab.local"},
       "password":"AlicePass!234"}'
```

The reply repeats the pattern: user
ID, home server, a **fresh** access
token, and a fresh **device ID**. Hold
onto that device idea. Every login
mints a device — a phone, a browser
tab, this `curl` — and the server
keeps them distinct, which is how a
client can later show "your sessions"
and how logging out one device need
not kill the others. The token is a
bearer key: whoever presents it *is*
alice, as far as the server can tell,
until it is revoked. Clients guard
theirs; the lab keeps its in files
inside the lab folder and deletes
them with it.

The check that a token works is
`/_matrix/client/v3/account/whoami`,
which answers with the user and
device the token belongs to (t04).
When a request ever puzzles you,
whoami is the first witness to call.

## The first room

Alice creates the room (t05):

```bash
curl -s -X POST .../_matrix/client/v3/createRoom \
  -H "Authorization: Bearer <alice's token>" \
  -d '{"name":"The Hobby Club",
       "topic":"A test room for the lab",
       "preset":"private_chat",
       "room_alias_name":"hobby-club"}'
```

Two identifiers come back into the
story. The **room ID** —
`!MvRSxCPghox--9v33vm6GHee9eraBdJaVfa4mUBI-fg`
— is the room's true name, and on
the current room version (12, the
default this Synapse creates) it is
an opaque hash with no server name
inside it. The **alias**,
`#hobby-club:lab.local`, is the human
address, and the directory call
resolves it to the ID (t05). People
share aliases; programs use IDs.

The `private_chat` preset set the
room's join rule to **invite**: nobody
enters uninvited. Alice invites bob
with a post to the room's `invite`
address; the empty `{}` that comes
back is success wearing no costume.
Bob's side of the story is visible in
his **sync** — the one call every
client makes constantly, asking
"what is new for me?" With
`full_state=true`, the lab's capture
shows The Garden Shed, a second room
alice made for the purpose, sitting
under `invited_rooms`, its invite
carrying the room's name and alice's
name (t06b). Accepting is a post to
`join`, after which `joined_rooms`
and the room's `joined_members` both
list the pair of them (t06).

A warning the lab earned and chapter
13 keeps: a one-shot sync can lag
the truth. More than once, the lab's
sync answers disagreed with the room
endpoints about what bob had joined
(t12). The endpoints never disagreed
with each other. When it matters,
believe them.

## Talking, and reading it back

A message is a `PUT`, not a `POST` —
the address ends in a transaction
ID you choose, so that a retried
send cannot deliver twice:

```bash
curl -s -X PUT .../rooms/<room id>/send/m.room.message/txn1 \
  -H "Authorization: Bearer <alice's token>" \
  -d '{"msgtype":"m.text",
       "body":"Hello Bob — the club room is open."}'
```

The reply is an **event ID** (`$…`) —
the message is now an event in the
room's history, signed into the
shared record chapter 1 promised.
Bob answers the same way (t07), and
reading back is a `GET` on the room's
`messages` with a direction and a
limit (t08). Newest first, the reply
holds both messages; reversed, they
read as the conversation happened:

```text
@alice:lab.local: Hello Bob — the club room is open.
@bob:lab.local: Hello Alice — I can see the room.
```

That is a chat server, whole: two
accounts, one room, a conversation
the server can prove it holds.

## The admin way in

Chapter 3 left registration open for
the lab's sake. A closed server adds
people differently: the config's
`registration_shared_secret` — minted
when the config was generated — keys
an HMAC dance at
`/_synapse/admin/v1/register` (t13).
The endpoint hands out a nonce; you
answer with a hash of the nonce, the
new username, the password, and the
word `admin` or `notadmin`, all keyed
by the secret. Carol was added that
way and logged in at once. One detail
the lab verified the hard way, by an
`HMAC incorrect` refusal and a read
of the server's own source: current
Synapse wants the word `notadmin`
where older write-ups said `user`.
When a recipe and the server
disagree, the server is the
documentation that counts.

**Check:** bob's read-back in t08 —
two messages, two senders, one room.
If your server can do that, chapter 5
can start asking who is *allowed* to
do what.
