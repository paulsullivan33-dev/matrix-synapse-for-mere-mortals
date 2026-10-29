# Choosing a Client

By the end of this chapter you will
know what a client actually does all
day, how to point one at your own
server instead of matrix.org, and
what the honest questions are when
choosing among Element and its
rivals. The lab drove the API with
`curl`; this chapter is about the
programs that do that driving for
humans, and it is labelled plainly:
**no client was run in the lab.**
Everything here about the apps
themselves is from their
documentation. Everything about what
they *do on the wire* is what the
previous chapters verified.

**Check:** the check is a sentence
you can now say with evidence behind
it — "when I press send, my client
makes the same `PUT` the lab made in
t07, and when my screen refreshes, it
is the sync from t06b arriving." If
that reads as obvious now, the
chapter's foundation is already laid.

## What a client does all day

Strip a chat app to its working day
and three jobs remain. It **logs in**
(chapter 4's call), receiving a token
and a device ID, and guards them. It
**syncs**, endlessly: one long-lived
request that the server answers
whenever anything happens — a
message, an invite, a name change —
so the app is really a rendering of
the sync stream, kept current. And
it **sends**, turning your keystrokes
into events with transaction IDs, so
a retried send on a flaky network
does not double-post. Everything else
— the bubbles, the themes, the emoji
pickers — is presentation. That is
also why the lab's sync warning
(t12) matters to real users: a client
whose sync lags is a client showing
you a slightly old world, and
restarting it forces a fresh one.

## Pointing a client at your server

Every serious client can use any
homeserver, not just matrix.org. The
moment that matters is the sign-in
screen's quiet corner: a "change
server" or "advanced" option where
you give your server's address — for
a real deployment, its public name;
the client then fetches that server's
own configuration (a `.well-known`
document, chapter 7's territory) and
talks to it directly. A client that
cannot be pointed elsewhere is not a
Matrix client in any useful sense; it
is one company's app wearing the
protocol as a costume. Check for the
option before falling for the polish.

## The field, briefly

**Element** is the reference client —
web, desktop and mobile — from the
team closest to the protocol, and the
one most documentation assumes. Its
newer mobile line, **Element X**, is
a faster rebuild on a newer engine.
Beyond them, the protocol's openness
shows: **FluffyChat** (friendly,
mobile-first), **Nheko** and
**NeoChat** (native desktop apps),
**SchildiChat** (an Element relative
with different defaults), and others,
down to terminal clients for the
`curl`-minded. They interoperate
because they must: same API, same
events. Choice among them is taste,
platform, and how each handles the
next section's subject. This guide
recommends starting with Element —
not because the others fail, but
because when you are learning, the
client the documentation pictures is
the one whose screen you can match
against the words.

## Encryption, without theatre

Matrix rooms can be **end-to-end
encrypted**: clients scramble
messages so that servers — including
yours — carry ciphertext they cannot
read. The machinery is real and, in
modern clients, largely automatic:
each device has keys, new devices
ask to be **verified** by an existing
one (an emoji or QR ceremony), and a
room's settings carry the switch —
priced at power level 100 in the
lab's room (t10), because turning it
on is meant to be an admin's
deliberate act.

Three honest sentences, because this
guide did not run any of it. First,
encryption protects message *content*
from servers; it does not hide *who
talks in which room*, which the
servers must know to do their job.
Second, your keys live and die with
your devices and your recovery
arrangements: lose every device and
your key backup, and old encrypted
history is gone in a way no admin —
not even you, on your own server —
can reverse. Third, encrypted rooms
trade away conveniences: server-side
search and easy history for new
devices are weaker there. None of
that argues against encryption. It
argues for enabling it with your
eyes open, in the rooms that warrant
it — which is exactly what the
100-level price tag is saying.

## Push, the quiet dependency

One more piece of a client's day is
easy to miss: when the app is
closed, something must wake it.
Mobile clients rely on push
notification gateways — for the
official apps, services run for that
purpose — so "my own server" still
involves a small outside dependency
for timely pings, unless you arrange
alternatives. It changes nothing the
server holds, but a privacy audit
that stops at the server is
incomplete, and this guide would
rather say so.

**Check:** pick the client you would
install first and answer for it:
where is its change-server option,
what happens to its token if the
phone is lost, and where would its
encryption keys be backed up. Those
three answers — not the theme colour
— are the choice.
