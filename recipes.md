# Recipes

Four jobs a small server's owner does
again and again, each one performed
by the lab and read back, so every
recipe ends in proof rather than in
hope. Tokens below are the ones your
own logins produced (chapter 4); the
room is the lab's Hobby Club
(`!MvRSxCPghox--9v33vm6GHee9eraBdJaVfa4mUBI-fg`,
alias `#hobby-club:lab.local`).

## Add a user, with registration closed

The standing way a closed server
grows. Evidence: t13.

1. Ask the admin endpoint for a
   nonce:
   `GET /_synapse/admin/v1/register`.
2. Compute the reply: HMAC-SHA1,
   keyed by the config's
   `registration_shared_secret`, over
   the fields joined by NUL bytes —
   nonce, username, password, and the
   word `admin` or `notadmin`. (On
   Synapse 1.164.1 the last word is
   `notadmin`; the lab met an older
   write-up saying `user` and was
   refused with `HMAC incorrect`.)
3. `POST` nonce, username, password,
   `admin: false`, and the hash to
   the same address.
4. **Proof:** the reply names the new
   user ID, and the new user can log
   in (chapter 4's call) — carol
   could, once the lab's own
   rate-limit wait expired.

## Make a moderator (and check they are one)

Evidence: t10.

1. `GET` the room's
   `state/m.room.power_levels` and
   keep the whole document.
2. Add one entry to its `users` map:
   `"@bob:lab.local": 50`.
3. `PUT` the whole document back to
   the same address. The reply is the
   new state event's ID.
4. **Proof:** `GET` the state again —
   ideally *as bob* — and see the 50
   in the `users` map. Fifty buys
   kicking, banning and tending room
   state; it does not buy rewriting
   the power levels themselves
   (that is priced at 100).

## Open a room's doors — and close them again

Evidence: t09.

1. `PUT` to the room's
   `state/m.room.join_rules` the body
   `{"join_rule":"public"}`.
2. **Proof:** `GET` the same state;
   it must say `public`.
3. To close the doors, `PUT`
   `{"join_rule":"invite"}` and read
   back `invite`.
4. Treat step 2 as the recipe's
   point, not its garnish: the lab
   performed the round trip precisely
   so the read-back habit is the one
   that survives.

## Find a room by its alias, and see who is in it

Evidence: t05 and t06.

1. `GET /_matrix/client/v3/directory/room/%23hobby-club%3Alab.local`
   (the alias, URL-escaped). The
   reply gives the room ID and the
   servers that know the room.
2. `GET` the room's `joined_members`
   with any member's token.
3. **Proof:** the reply lists the
   joined users with their display
   names — alice and bob, in the lab —
   which is also the fastest health
   check a room has: if the list is
   not who you expect, the room's
   recent history is where to look,
   and the `messages` call from
   chapter 4 shows it.
