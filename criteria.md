# Writing criteria for this guide

Every "for Mere Mortals" guide is written to the same nine-point
standard, so a reader who trusts one can trust the rest. Here it
is, with the verification notes for this particular guide below.

1. **Fix it first.** Reader outcomes lead, not action items: each
   chapter opens by naming the outcome it delivers, shows a check
   the reader can run to confirm they got it, and a reasonable
   reader finishes able to state what was done, what it means,
   and what to try next.
2. **Plain language.** Short sentences, everyday vocabulary,
   technical terms defined on first use. No slang, and no
   idioms that only make sense in one country — the reader may
   be translating as they go.
3. **No dead ends.** A guide never tells the reader to do
   something it cannot show them how to verify. Every claim a
   reader relies on — an install, a command, an output — is
   something this guide demonstrates or clearly labels
   documented-only below.
4. **Live-verified where it matters.** Procedures are run for
   real in the guide's lab wherever the build machine allows it,
   and the transcripts kept in the repository are the evidence.
   What could not be run is listed honestly below, never
   presented as if it had been.
5. **General audiences.** Nothing in this guide — examples,
   fixtures, names, addresses — is modelled on any particular
   reader or author's real life, network, or organisations.
   The lab's sentences are stock sentences and pangrams.
6. **Standalone.** A reader needs this guide, its lab, and
   nothing else. Where another guide would genuinely help, it
   is pointed to once, by name, and the chapter still completes
   without it.
7. **Honest about limits.** Chapter 11 names what the tool
   cannot do: a server name that can never change, a database
   that only grows, federated copies that cannot be recalled,
   encryption keys whose loss no admin can reverse, one server
   as one point of failure, and this guide's own evidence
   fence, stated in the chapter itself.
8. **The ethics rule is in the text, early.** Running a chat
   server makes you the holder of other people's conversations,
   so chapter 1 and the README draw the line before any
   procedure depends on it: accounts on your server are other
   people's speech in your keeping, federation copies that
   speech beyond your recall (chapter 7), and an admin's powers
   — reading state, resetting passwords — are stewardship, not
   ownership. Where the server genuinely cannot see (encrypted
   rooms) the text says so in chapter 6 rather than implying
   otherwise.
9. **Builds clean.** The site builds with MkDocs in strict mode
   with no warnings, and a fresh reader following the chapters
   in order reaches the stated outcome of each.

## Verification notes for this guide

The lab ran **Synapse 1.164.1** (the `matrix-synapse` PyPI
package) in a fresh Python 3.12 virtual environment on the
build machine, serving the invented server name `lab.local`
on loopback only (127.0.0.1 and ::1, port 8008), with SQLite
as its database. The generated config was edited in exactly
two ways, both shown in transcript t01: the federation
resource was removed from the listener, and registration was
opened (with verification off) for the lab only. All
transcripts live in `matrix-lab/transcripts/`; the driver
scripts that produced them are the `run-lab*.sh` files in
`matrix-lab/`. The lab users — alice, bob and carol — and the
rooms (The Hobby Club, The Garden Shed) are invented
fixtures; the passwords used (`AlicePass!234`, `BobPass!345`,
`CarolPass!567`) are throwaways for a server that was deleted
with the lab, and the access tokens visible in transcripts
died with it.

Run for real, with transcripts as evidence:

- Install from PyPI and the version read back from the
  package itself (t00). Config generation, the signing key's
  creation, and the lab's two config edits (t01).
- First contact: the client versions endpoint listing
  r0.0.1–v1.17, and the root page's redirect (t02).
- Registration as a two-step UIAA flow: the empty post's 401
  with session and the `m.login.dummy` flow, then completion
  returning `@alice:lab.local` with token and device (t03);
  bob the same way, then password logins for both and a
  `whoami` check (t04).
- Room creation under room version 12 — the opaque hash room
  ID with no server suffix — the alias `#hobby-club:lab.local`
  resolved through the directory, and an invite sent (t05).
- The invite arriving: bob's sync (`full_state=true`) showing
  the second room under `invited_rooms` with its name and the
  invite event; joining, `joined_rooms` and `joined_members`
  agreeing (t06, t06b).
- Messages both ways, each returning an event ID (t07), and
  the history read back through the messages endpoint in both
  orders (t08).
- Join rules read (`invite`), changed to `public`, read back,
  restored to `invite`, read back (t09).
- Power levels read at birth (empty users map, 0/50/100
  prices), bob promoted to 50 by a full-document PUT and the
  result read back with bob's own token; the create event
  fetched to show where the creator's authority lives (t10).
- Failures in the server's own words: wrong-password login
  (`M_FORBIDDEN`, deliberately vague), duplicate registration
  (`M_USER_IN_USE`), a message to a nonexistent room
  (`M_FORBIDDEN`, not in room) (t11).
- The sync-freshness trap: one-shot sync answers (bare and
  `full_state`) disagreeing with the room endpoints and, at
  different moments, with each other, while the endpoints
  never disagreed (t12).
- A user added the admin way, registration notwithstanding:
  the shared-secret nonce/HMAC flow at
  `/_synapse/admin/v1/register` — including the verified
  detail that Synapse 1.164.1 signs the word `notadmin`,
  where older write-ups say `user`, which the server refused
  with `HMAC incorrect` before the lab read the answer out of
  the installed source — followed by the login rate limit
  (`M_LIMIT_EXCEEDED`) the lab's earlier failures had tripped,
  and carol's successful login after the stated wait (t13).
- The server on disk at the end: a 2.2 MB SQLite database
  (plus its write-ahead log), the 59-byte signing key, and
  an empty media store (t14).

Documented only — described from the project's documentation,
not run, and the text does not claim otherwise:

- **Federation, entire** (chapter 7): discovery via
  `.well-known`, certificates, the federation listener in
  service, the project's federation tester, allowlists, and
  every consequence described there. The lab server could
  not federate — its name exists in no DNS and its federation
  listener was removed — and the chapter says so at its head.
- **Clients on screens** (chapter 6): Element, Element X and
  the other named clients were not installed; their
  behaviour is characterised from their documentation. What
  they do on the wire is the API the lab verified.
- **End-to-end encryption**: key verification ceremonies,
  cross-signing, key backup and recovery were not exercised;
  two `curl` scripts have no keys worth protecting. Chapter 6
  states the properties and the costs without claiming a run.
- **Spaces** (glossary): never created in the lab.
- **The Docker and package install routes**, running behind
  a reverse proxy with real certificates, and running
  against **PostgreSQL** (chapter 8's migration included):
  only the pip/SQLite route was run.
- **Media in anger**: uploads, thumbnails, remote-media
  caching and the retention settings of chapter 8. The lab
  sent text only; its media store stayed empty (t14).
- **Room history purging and state compression** at scale,
  knock and space-based join rules, worker processes, and
  push notification gateways (chapter 6's note included):
  named, not run.

Fixtures are this guide's own and deliberately generic: three
invented users, a hobby club and a garden shed, two stock
greetings — no real people, organisations, servers or events.
