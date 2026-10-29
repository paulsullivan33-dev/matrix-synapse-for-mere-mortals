# Rooms and Permissions

By the end of this chapter you will be
able to control who may enter a room
and who may run it: the join rules
that guard the door, and the power
levels that divide members from
moderators from admins — both changed
through the API, and both read back
to prove the change took.

**Check:** the lab's evidence is two
read-backs. The join rules fetched
*after* the change say what the
change set (t09), and the power
levels fetched by *bob* show his own
name at 50 (t10). A permission you
cannot read back is a rumour; this
chapter deals only in read-backs.

## A room is its state

Chapter 4 called everything in a room
an event. The room's *settings* are
events too — special ones called
**state events**, one per kind, whose
current values together describe the
room as it stands: its name, its
topic, its join rules, its power
levels. Reading a setting is a `GET`
on the room's `state` at the kind you
want; changing it is a `PUT` of the
same shape. There is no separate
settings database to wonder about.
The room is its history, and its
present settings are simply the
latest state events in it.

## The door: join rules

The `m.room.join_rules` state holds
one value that matters most days,
`join_rule`. The lab's room, born
from the `private_chat` preset,
started at:

```bash
curl -s .../rooms/<room id>/state/m.room.join_rules \
  -H "Authorization: Bearer <alice's token>"
# {"join_rule": "invite"}
```

`invite` means the door opens only
for the invited — the correct default
for a club room, a family room, a
work room. Alice changed it to
`public` with a `PUT` of
`{"join_rule":"public"}` and read it
back as `public` (t09): now anyone
whose server can reach the room may
walk in. Then — because a guide
should model the habit it teaches —
she put it back to `invite`, and the
final read-back says `invite` again.
Public is a legitimate choice for
public topics; it is a poor accident.
The rule you mean to have is the rule
a read-back shows you.

Other values exist for doors with
finer manners — `knock`, where
strangers may ask and members decide,
and rules that tie a room to a parent
space — and they are documented-only
here: the lab exercised the two ends
of the door, shut and open, and those
are the ones this chapter claims.

## The pecking order: power levels

Who may *do* things inside the room
is the `m.room.power_levels` state.
It is a table of numbers. Every user
has a level (default 0); every kind
of act has a price. The lab's room
was born with these terms (t10):

```text
users_default   0     state_default   50
invite          0     kick            50
ban             50    redact          50
```

Read it as sentences. Anyone (0) may
invite. Changing the room's state —
its name, its rules, this very table —
costs 50. Kicking and banning cost
50. Sending an ordinary message is
not in the table's expensive seats:
the default for plain events is 0, so
everyone may talk. A finer table
inside, `events`, names special
prices: changing power levels
themselves costs **100**, and so does
turning on encryption — the two acts
a room should never let a merely
trusted member perform.

Alice promoted bob with a `PUT` of
the whole document, one entry added
to its `users` map:

```text
"users": {"@bob:lab.local": 50}
```

Bob read the table back and saw his
own 50 (t10): a moderator, able to
kick, ban, and tend the room's state,
unable to rewrite the pecking order
itself. That shape — 0 for members,
50 for moderators, 100 for admins —
is the pattern nearly every Matrix
room you will ever join is running.

## Where the creator's 100 lives

One entry in the lab's first
power-level read-back looks like a
bug: the `users` map was **empty**,
though alice plainly ran the room —
she invited, she changed state, she
promoted. Her 100 is real but stored
elsewhere. The room's **create
event**, fetched in t10, names her as
the room's creator, and on the
current room version (12) that is
where the creator's authority lives:
implied by the create event, not
repeated in the users map. Two
lessons follow. Never conclude from
an empty `users` map that a room has
no admin. And know that the creator
is load-bearing: a room whose
creator's account is gone keeps its
implied 100 pointed at nobody, which
is one reason old rooms grow hard to
govern.

**Check:** read your room's
`m.room.power_levels` and find, in
order, the price of talking, the
price of kicking, and the price of
changing power levels — 0, 50, 100 in
the lab's room. If you can also name
who holds 100 and *where that fact
lives*, you understand rooms better
than most people who chat in them
daily.
