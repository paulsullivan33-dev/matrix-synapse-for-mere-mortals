# Installing Synapse

By the end of this chapter you will
have Synapse installed the way the
lab installed it, a generated config
with two deliberate edits, and a
server that answers its first check:
the versions endpoint, fetched with
`curl`, listing the protocol versions
it speaks.

**Check:** the check is the chapter's
last step and transcript t02:

```bash
curl -s http://127.0.0.1:8008/_matrix/client/versions
```

Any JSON answer at all — even before
a single user exists — means a
homeserver is alive.

## The routes, honestly

There are three common ways to get
Synapse onto a machine. The project's
own recommendation for most people is
its **Docker image**, and a great many
real servers run that way; the Docker
Compose guide in this series covers
the machinery. **Distribution
packages** exist for some systems.
And there is the **Python package**,
installed with `pip` into a virtual
environment — the route this lab ran,
because the lab's machine has no
container runtime, and because the
Python route leaves every file where
you can see it, which suits a guide.
All three routes run the same
program; the chapters after this one
do not care which you took.

## The lab's install

Python 3 and a fresh virtual
environment, both inside the lab's
own folder — nothing installed
system-wide:

```bash
python3 -m venv venv
venv/bin/pip install matrix-synapse
```

That is the whole install. The lab's
transcript t00 records the result:
**matrix-synapse 1.164.1**. Check your
own with:

```bash
venv/bin/python -c "import synapse; print(synapse.__version__)"
```

## Generate the config

Synapse writes its own first config,
and mints its signing key in the same
breath. This is the moment the server
name is chosen — chapter 1's
five-minute decision happens here:

```bash
venv/bin/python -m synapse.app.homeserver \
  --server-name lab.local \
  --config-path homeserver.yaml \
  --data-directory . \
  --generate-config --report-stats=no
```

Three files appear (t01): the config,
a log config, and
`lab.local.signing.key`. Two details
are worth noticing in the generated
config before touching anything.
`report_stats: false` — the lab
declined the project's anonymous
usage statistics, and the flag is
right there to see. And the database
is already SQLite at a path inside
the data directory, which is what a
small server wants. The listener
binds to loopback addresses
(127.0.0.1 and ::1) on port 8008 —
Synapse's generated default is a
server only this machine can reach,
which is the correct way to be born.

## The lab's two edits

Out of the box the listener does two
jobs, client and federation. The lab
removed one line's worth of job
(t01):

```yaml
    resources:
    - compress: false
      names:
      - client
```

With `federation` gone from the list,
no server-to-server API is served at
all. This is a lab choice, not a
recommendation for production —
chapter 7 is about turning it back
on, deliberately — but it makes the
lab's promise true: nothing outside
this machine's own clients can ask
this server for anything.

The second edit opens registration,
for the lab only:

```yaml
enable_registration: true
enable_registration_without_verification: true
```

Registration is **closed by default**,
and closed is right for a real server:
an open door on the internet fills
with strangers and spam within days.
The lab opens it so chapter 4 can
show the registration flow itself;
chapter 4 also shows the admin way of
adding users, which is how a closed
server grows. If you take one habit
from this chapter, take this one: the
defaults are the safe ones, and every
edit away from them should have a
reason you can say out loud.

## Start it, and run the check

```bash
venv/bin/python -m synapse.app.homeserver -c homeserver.yaml
```

First startup builds the database
schema and takes a little while;
later starts are quick. The log
(homeserver.log) records it listening.
Then the check from the top of the
chapter. The lab's answer (t02) lists
versions from `r0.0.1` to `v1.17` —
the protocol dialects this server can
speak to clients — and the bare root
address answers with a small page
redirecting to a static "it works"
note. That is a homeserver: alive,
unnamed by any user, waiting.

**Check:** re-run the versions curl
and count what it proves — a process
listening on 8008, speaking the
client API, on the name you chose.
Chapter 4 gives it people.
