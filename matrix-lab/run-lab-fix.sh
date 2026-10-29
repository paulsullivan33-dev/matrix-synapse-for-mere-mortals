#!/bin/bash
BASE=http://127.0.0.1:8008
T=~/workspace/matrix-synapse-for-mere-mortals/matrix-lab/transcripts
W=~/workspace/matrix-lab-work
ALICE_TOKEN=$(jq -r .access_token "$W/tokens/alice-login.json")
BOB_TOKEN=$(jq -r .access_token "$W/tokens/bob-login.json")
ROOM2=$(jq -r .room_id "$W/tokens/room2.json")

{
  echo "# A second room ('The Garden Shed', created by alice in the"
  echo "# supplement step) exists so the invite can be seen arriving."
  echo "# Bob is invited to it and has not yet joined."
  echo
  echo "\$ curl -s '$BASE/_matrix/client/v3/sync?timeout=0&full_state=true' -H 'Authorization: Bearer <bob>'   (excerpt)"
  curl -s "$BASE/_matrix/client/v3/sync?timeout=0&full_state=true" -H "Authorization: Bearer $BOB_TOKEN" \
    | jq '{invited_rooms: (.rooms.invite // {} | keys), joined_rooms: (.rooms.join // {} | keys)}'
  echo
  echo "# The invitation itself, as the sync delivers it — the room's"
  echo "# name and alice's invite, which is all a client needs to show"
  echo "# 'alice invited you to The Garden Shed':"
  curl -s "$BASE/_matrix/client/v3/sync?timeout=0&full_state=true" -H "Authorization: Bearer $BOB_TOKEN" \
    | jq ".rooms.invite[\"$ROOM2\"].invite_state.events[] | select(.type==\"m.room.name\" or .type==\"m.room.member\") | {type, sender, name: .content.name, membership: .content.membership}"
  echo
  echo "\$ curl -s -X POST $BASE/_matrix/client/v3/join/$ROOM2 -d '{}'   (as bob)"
  curl -s -X POST "$BASE/_matrix/client/v3/join/$ROOM2" -H "Authorization: Bearer $BOB_TOKEN" -H 'Content-Type: application/json' -d '{}' | jq .
  echo
  echo "\$ curl -s $BASE/_matrix/client/v3/joined_rooms -H 'Authorization: Bearer <bob>'"
  curl -s $BASE/_matrix/client/v3/joined_rooms -H "Authorization: Bearer $BOB_TOKEN" | jq .
} > "$T/t06b-the-invite-arriving.txt" 2>&1

{
  echo "# A trap the lab met while capturing the invite in t06: a"
  echo "# bare first sync (no full_state) can answer with a STALE"
  echo "# snapshot. Ground truth first, from the dedicated endpoints:"
  echo
  echo "\$ curl -s $BASE/_matrix/client/v3/joined_rooms -H 'Authorization: Bearer <bob>'"
  TRUTH=$(curl -s $BASE/_matrix/client/v3/joined_rooms -H "Authorization: Bearer $BOB_TOKEN")
  echo "$TRUTH" | jq .
  echo
  echo "\$ curl -s '$BASE/_matrix/client/v3/sync?timeout=0' -H 'Authorization: Bearer <bob>'   (excerpt)"
  BARE=$(curl -s "$BASE/_matrix/client/v3/sync?timeout=0" -H "Authorization: Bearer $BOB_TOKEN" | jq -c '{invited_rooms: (.rooms.invite // {} | keys), joined_rooms: (.rooms.join // {} | keys)}')
  echo "$BARE" | jq .
  echo
  echo "\$ curl -s '$BASE/_matrix/client/v3/sync?timeout=0&full_state=true' -H 'Authorization: Bearer <bob>'   (excerpt)"
  FULL=$(curl -s "$BASE/_matrix/client/v3/sync?timeout=0&full_state=true" -H "Authorization: Bearer $BOB_TOKEN" | jq -c '{invited_rooms: (.rooms.invite // {} | keys), joined_rooms: (.rooms.join // {} | keys)}')
  echo "$FULL" | jq .
  echo
  TJ=$(echo "$TRUTH" | jq -c '.joined_rooms | sort')
  BJ=$(echo "$BARE" | jq -c '.joined_rooms | sort')
  FJ=$(echo "$FULL" | jq -c '.joined_rooms | sort')
  echo "# Verdict at capture time: joined_rooms endpoint says $TJ."
  if [ "$BJ" != "$TJ" ]; then echo "# The bare sync DISAGREED (it said $BJ)."; else echo "# This time the bare sync agreed; during the t06 capture it did not."; fi
  if [ "$FJ" = "$TJ" ]; then echo "# The full_state sync AGREED."; else echo "# The full_state sync said $FJ."; fi
  echo "# Lesson written into the troubleshooting chapter: when sync"
  echo "# and the room endpoints disagree, believe the endpoints and"
  echo "# check again with full_state before concluding anything."
} > "$T/t12-the-stale-sync.txt" 2>&1
echo done
