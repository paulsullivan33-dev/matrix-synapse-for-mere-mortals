#!/bin/bash
# Lab driver for the Matrix (Synapse) guide. Talks to the lab
# homeserver on loopback and saves one transcript per step.
BASE=http://127.0.0.1:8008
T=~/workspace/matrix-synapse-for-mere-mortals/matrix-lab/transcripts
W=~/workspace/matrix-lab-work
mkdir -p "$T" "$W/tokens"

step() { echo; echo "\$ $1"; }

# --- t02: versions endpoint -------------------------------------
{
  step "curl -s $BASE/_matrix/client/versions | jq ."
  curl -s $BASE/_matrix/client/versions | jq '{versions: .versions, unstable_features: (.unstable_features | keys | length)}'
  echo
  step "curl -s $BASE/   (the root page)"
  curl -s $BASE/ | head -8
} > "$T/t02-versions-endpoint.txt" 2>&1

# --- t03: register alice (UIAA flow) -----------------------------
{
  step "curl -s -X POST $BASE/_matrix/client/v3/register -d '{}'   # step 1: ask how to prove ourselves"
  RESP=$(curl -s -w '\nHTTP %{http_code}' -X POST $BASE/_matrix/client/v3/register -H 'Content-Type: application/json' -d '{}')
  echo "$RESP"
  SESSION=$(echo "$RESP" | sed -n 's/.*"session": "\([^"]*\)".*/\1/p' | head -1)
  echo
  echo "# The server answered 401 with a session id and the flows it accepts."
  echo "# The lab completes the 'm.login.dummy' stage using that session:"
  step "curl -s -X POST .../register -d '{\"username\":\"alice\",\"password\":\"AlicePass!234\",\"auth\":{\"type\":\"m.login.dummy\",\"session\":\"<session from step 1>\"}}'"
  curl -s -X POST $BASE/_matrix/client/v3/register -H 'Content-Type: application/json' \
    -d "{\"username\":\"alice\",\"password\":\"AlicePass!234\",\"auth\":{\"type\":\"m.login.dummy\",\"session\":\"$SESSION\"}}" \
    | tee "$W/tokens/alice-register.json" | jq .
} > "$T/t03-register-alice.txt" 2>&1
ALICE_TOKEN=$(jq -r .access_token "$W/tokens/alice-register.json")

# --- t04: register bob, then log both in -------------------------
{
  step "# bob registers the same way (session dance condensed)"
  RESP=$(curl -s -X POST $BASE/_matrix/client/v3/register -H 'Content-Type: application/json' -d '{}')
  SESSION=$(echo "$RESP" | sed -n 's/.*"session": "\([^"]*\)".*/\1/p' | head -1)
  curl -s -X POST $BASE/_matrix/client/v3/register -H 'Content-Type: application/json' \
    -d "{\"username\":\"bob\",\"password\":\"BobPass!345\",\"auth\":{\"type\":\"m.login.dummy\",\"session\":\"$SESSION\"}}" \
    | tee "$W/tokens/bob-register.json" | jq '{user_id, home_server}'
  echo
  step "curl -s -X POST $BASE/_matrix/client/v3/login -d '{\"type\":\"m.login.password\",\"identifier\":{\"type\":\"m.id.user\",\"user\":\"@alice:lab.local\"},\"password\":\"AlicePass!234\"}'"
  curl -s -X POST $BASE/_matrix/client/v3/login -H 'Content-Type: application/json' \
    -d '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"@alice:lab.local"},"password":"AlicePass!234"}' \
    | tee "$W/tokens/alice-login.json" | jq '{user_id, home_server, device_id, access_token: (.access_token[0:12] + "...")}'
  echo
  step "curl -s -X POST $BASE/_matrix/client/v3/login   (bob, same shape)"
  curl -s -X POST $BASE/_matrix/client/v3/login -H 'Content-Type: application/json' \
    -d '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"@bob:lab.local"},"password":"BobPass!345"}' \
    | tee "$W/tokens/bob-login.json" | jq '{user_id, home_server, device_id, access_token: (.access_token[0:12] + "...")}'
  echo
  step "curl -s $BASE/_matrix/client/v3/account/whoami -H 'Authorization: Bearer <alice token>'"
  curl -s $BASE/_matrix/client/v3/account/whoami -H "Authorization: Bearer $ALICE_TOKEN" | jq .
} > "$T/t04-register-bob-and-login.txt" 2>&1
BOB_TOKEN=$(jq -r .access_token "$W/tokens/bob-login.json")
ALICE_TOKEN=$(jq -r .access_token "$W/tokens/alice-login.json")

# --- t05: alice creates the room and invites bob ------------------
{
  step "curl -s -X POST $BASE/_matrix/client/v3/createRoom -H 'Authorization: Bearer <alice>' -d '{...}'"
  echo '  {"name":"The Hobby Club","topic":"A test room for the lab",'
  echo '   "preset":"private_chat","room_alias_name":"hobby-club"}'
  curl -s -X POST $BASE/_matrix/client/v3/createRoom -H "Authorization: Bearer $ALICE_TOKEN" -H 'Content-Type: application/json' \
    -d '{"name":"The Hobby Club","topic":"A test room for the lab","preset":"private_chat","room_alias_name":"hobby-club"}' \
    | tee "$W/tokens/room.json" | jq .
  ROOM_ID=$(jq -r .room_id "$W/tokens/room.json")
  echo
  step "curl -s $BASE/_matrix/client/v3/directory/room/%23hobby-club%3Alab.local"
  curl -s "$BASE/_matrix/client/v3/directory/room/%23hobby-club%3Alab.local" | jq .
  echo
  step "curl -s -X POST $BASE/_matrix/client/v3/rooms/$ROOM_ID/invite -d '{\"user_id\":\"@bob:lab.local\"}'   (as alice)"
  curl -s -X POST "$BASE/_matrix/client/v3/rooms/$ROOM_ID/invite" -H "Authorization: Bearer $ALICE_TOKEN" -H 'Content-Type: application/json' \
    -d '{"user_id":"@bob:lab.local"}' | jq .
  echo "(empty JSON object = success)"
} > "$T/t05-create-room-and-invite.txt" 2>&1
ROOM_ID=$(jq -r .room_id "$W/tokens/room.json")
echo "$ROOM_ID" > "$W/tokens/room-id.txt"

# --- t06: bob sees the invite and joins ----------------------------
{
  step "curl -s '$BASE/_matrix/client/v3/sync?timeout=0' -H 'Authorization: Bearer <bob>'   (excerpt)"
  curl -s "$BASE/_matrix/client/v3/sync?timeout=0" -H "Authorization: Bearer $BOB_TOKEN" | jq ".rooms | {invite: (.invite | keys), join: (.join | keys)}"
  echo
  step "curl -s -X POST $BASE/_matrix/client/v3/join/$ROOM_ID -d '{}'   (as bob)"
  curl -s -X POST "$BASE/_matrix/client/v3/join/$ROOM_ID" -H "Authorization: Bearer $BOB_TOKEN" -H 'Content-Type: application/json' -d '{}' | jq .
  echo
  step "curl -s $BASE/_matrix/client/v3/joined_rooms -H 'Authorization: Bearer <bob>'"
  curl -s $BASE/_matrix/client/v3/joined_rooms -H "Authorization: Bearer $BOB_TOKEN" | jq .
  echo
  step "curl -s $BASE/_matrix/client/v3/rooms/$ROOM_ID/joined_members -H 'Authorization: Bearer <alice>'"
  curl -s "$BASE/_matrix/client/v3/rooms/$ROOM_ID/joined_members" -H "Authorization: Bearer $ALICE_TOKEN" | jq .
} > "$T/t06-bob-joins.txt" 2>&1

# --- t07: messages both ways ---------------------------------------
{
  step "PUT .../rooms/$ROOM_ID/send/m.room.message/txn1   (alice)"
  echo '  {"msgtype":"m.text","body":"Hello Bob — the club room is open."}'
  curl -s -X PUT "$BASE/_matrix/client/v3/rooms/$ROOM_ID/send/m.room.message/txn1" -H "Authorization: Bearer $ALICE_TOKEN" -H 'Content-Type: application/json' \
    -d '{"msgtype":"m.text","body":"Hello Bob — the club room is open."}' | jq .
  echo
  step "PUT .../rooms/$ROOM_ID/send/m.room.message/txn2   (bob)"
  echo '  {"msgtype":"m.text","body":"Hello Alice — I can see the room."}'
  curl -s -X PUT "$BASE/_matrix/client/v3/rooms/$ROOM_ID/send/m.room.message/txn2" -H "Authorization: Bearer $BOB_TOKEN" -H 'Content-Type: application/json' \
    -d '{"msgtype":"m.text","body":"Hello Alice — I can see the room."}' | jq .
} > "$T/t07-messages-both-ways.txt" 2>&1

# --- t08: read the messages back -----------------------------------
{
  step "curl -s '$BASE/_matrix/client/v3/rooms/$ROOM_ID/messages?dir=b&limit=10' -H 'Authorization: Bearer <bob>'"
  curl -s "$BASE/_matrix/client/v3/rooms/$ROOM_ID/messages?dir=b&limit=10" -H "Authorization: Bearer $BOB_TOKEN" \
    | jq '[.chunk[] | select(.type=="m.room.message") | {sender, body: .content.body}]'
  echo
  echo "# The same two messages in the order they were sent:"
  curl -s "$BASE/_matrix/client/v3/rooms/$ROOM_ID/messages?dir=b&limit=10" -H "Authorization: Bearer $BOB_TOKEN" \
    | jq -r '[.chunk[] | select(.type=="m.room.message")] | reverse[] | "\(.sender): \(.content.body)"'
} > "$T/t08-read-back.txt" 2>&1

# --- t09: join rules ------------------------------------------------
{
  step "curl -s .../rooms/$ROOM_ID/state/m.room.join_rules -H 'Authorization: Bearer <alice>'"
  curl -s "$BASE/_matrix/client/v3/rooms/$ROOM_ID/state/m.room.join_rules" -H "Authorization: Bearer $ALICE_TOKEN" | jq .
  echo
  step "curl -s -X PUT .../rooms/$ROOM_ID/state/m.room.join_rules -d '{\"join_rule\":\"public\"}'   (alice)"
  curl -s -X PUT "$BASE/_matrix/client/v3/rooms/$ROOM_ID/state/m.room.join_rules" -H "Authorization: Bearer $ALICE_TOKEN" -H 'Content-Type: application/json' \
    -d '{"join_rule":"public"}' | jq .
  echo
  step "# read back:"
  curl -s "$BASE/_matrix/client/v3/rooms/$ROOM_ID/state/m.room.join_rules" -H "Authorization: Bearer $BOB_TOKEN" | jq .
  echo
  echo "# ...and put it back to invite-only, the safer default:"
  step "curl -s -X PUT .../state/m.room.join_rules -d '{\"join_rule\":\"invite\"}'   (alice)"
  curl -s -X PUT "$BASE/_matrix/client/v3/rooms/$ROOM_ID/state/m.room.join_rules" -H "Authorization: Bearer $ALICE_TOKEN" -H 'Content-Type: application/json' \
    -d '{"join_rule":"invite"}' | jq .
  curl -s "$BASE/_matrix/client/v3/rooms/$ROOM_ID/state/m.room.join_rules" -H "Authorization: Bearer $ALICE_TOKEN" | jq .
} > "$T/t09-join-rules.txt" 2>&1

# --- t10: power levels ----------------------------------------------
{
  step "curl -s .../rooms/$ROOM_ID/state/m.room.power_levels -H 'Authorization: Bearer <alice>'   (excerpt)"
  curl -s "$BASE/_matrix/client/v3/rooms/$ROOM_ID/state/m.room.power_levels" -H "Authorization: Bearer $ALICE_TOKEN" \
    | tee "$W/tokens/pl.json" | jq '{users, users_default, events: (.events | length), state_default, invite, kick, ban}'
  echo
  step "# alice promotes bob to moderator (power level 50) and reads it back:"
  jq '.users["@bob:lab.local"] = 50' "$W/tokens/pl.json" > "$W/tokens/pl-new.json"
  step "curl -s -X PUT .../state/m.room.power_levels -d '<the same document, with @bob:lab.local: 50 added to users>'"
  curl -s -X PUT "$BASE/_matrix/client/v3/rooms/$ROOM_ID/state/m.room.power_levels" -H "Authorization: Bearer $ALICE_TOKEN" -H 'Content-Type: application/json' \
    --data @"$W/tokens/pl-new.json" | jq .
  curl -s "$BASE/_matrix/client/v3/rooms/$ROOM_ID/state/m.room.power_levels" -H "Authorization: Bearer $BOB_TOKEN" | jq '.users'
} > "$T/t10-power-levels.txt" 2>&1

# --- t11: honest failures --------------------------------------------
{
  step "curl -s -X POST .../login   (alice, WRONG password)"
  curl -s -w '\nHTTP %{http_code}\n' -X POST $BASE/_matrix/client/v3/login -H 'Content-Type: application/json' \
    -d '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"@alice:lab.local"},"password":"NotThePassword1"}' | jq . 2>/dev/null || \
  curl -s -X POST $BASE/_matrix/client/v3/login -H 'Content-Type: application/json' \
    -d '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"@alice:lab.local"},"password":"NotThePassword1"}'
  echo
  step "# registering the same username a second time:"
  RESP=$(curl -s -X POST $BASE/_matrix/client/v3/register -H 'Content-Type: application/json' -d '{}')
  SESSION=$(echo "$RESP" | sed -n 's/.*"session": "\([^"]*\)".*/\1/p' | head -1)
  curl -s -w '\nHTTP %{http_code}\n' -X POST $BASE/_matrix/client/v3/register -H 'Content-Type: application/json' \
    -d "{\"username\":\"alice\",\"password\":\"AlicePass!234\",\"auth\":{\"type\":\"m.login.dummy\",\"session\":\"$SESSION\"}}"
  echo
  step "# a message to a room that does not exist:"
  curl -s -w '\nHTTP %{http_code}\n' -X PUT "$BASE/_matrix/client/v3/rooms/!nosuchroom:lab.local/send/m.room.message/txn9" -H "Authorization: Bearer $ALICE_TOKEN" -H 'Content-Type: application/json' \
    -d '{"msgtype":"m.text","body":"anyone there?"}'
} > "$T/t11-failures.txt" 2>&1

echo "lab run complete; room: $ROOM_ID"
