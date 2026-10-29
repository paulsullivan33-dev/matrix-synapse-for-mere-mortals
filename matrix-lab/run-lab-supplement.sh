#!/bin/bash
# Supplement: capture the invite arriving in bob's /sync (second
# room), and the room create event behind the creator's power level.
BASE=http://127.0.0.1:8008
T=~/workspace/matrix-synapse-for-mere-mortals/matrix-lab/transcripts
W=~/workspace/matrix-lab-work
ALICE_TOKEN=$(jq -r .access_token "$W/tokens/alice-login.json")
BOB_TOKEN=$(jq -r .access_token "$W/tokens/bob-login.json")
ROOM_ID=$(cat "$W/tokens/room-id.txt")

{
  echo "# A second room, created only so the invite can be seen arriving."
  echo
  echo "\$ curl -s -X POST $BASE/_matrix/client/v3/createRoom (alice) -d '{\"name\":\"The Garden Shed\",\"preset\":\"private_chat\"}'"
  curl -s -X POST $BASE/_matrix/client/v3/createRoom -H "Authorization: Bearer $ALICE_TOKEN" -H 'Content-Type: application/json' \
    -d '{"name":"The Garden Shed","preset":"private_chat"}' | tee "$W/tokens/room2.json" | jq .
  ROOM2=$(jq -r .room_id "$W/tokens/room2.json")
  echo
  echo "\$ curl -s -X POST .../rooms/$ROOM2/invite -d '{\"user_id\":\"@bob:lab.local\"}'   (as alice)"
  curl -s -X POST "$BASE/_matrix/client/v3/rooms/$ROOM2/invite" -H "Authorization: Bearer $ALICE_TOKEN" -H 'Content-Type: application/json' \
    -d '{"user_id":"@bob:lab.local"}' | jq .
  echo "(empty JSON object = success)"
  echo
  echo "\$ curl -s '$BASE/_matrix/client/v3/sync?timeout=0' -H 'Authorization: Bearer <bob>'   (excerpt)"
  curl -s "$BASE/_matrix/client/v3/sync?timeout=0" -H "Authorization: Bearer $BOB_TOKEN" \
    | jq '{invited_rooms: (.rooms.invite // {} | keys), joined_rooms: (.rooms.join // {} | keys)}'
  echo
  echo "# The invite carries the room's name, sent by alice:"
  curl -s "$BASE/_matrix/client/v3/sync?timeout=0" -H "Authorization: Bearer $BOB_TOKEN" \
    | jq ".rooms.invite[\"$ROOM2\"].invite_state.events[] | select(.type==\"m.room.name\" or .type==\"m.room.member\") | {type, sender, membership: .content.membership}"
} > "$T/t06b-the-invite-arriving.txt" 2>&1

{
  echo
  echo "# Why is alice's own name missing from the users map above?"
  echo "# The room's create event names her as creator; on the current"
  echo "# room version that is where the creator's power level lives."
  echo "\$ curl -s .../rooms/$ROOM_ID/state/m.room.create -H 'Authorization: Bearer <alice>'"
  curl -s "$BASE/_matrix/client/v3/rooms/$ROOM_ID/state/m.room.create" -H "Authorization: Bearer $ALICE_TOKEN" | jq .
} >> "$T/t10-power-levels.txt" 2>&1
echo done
