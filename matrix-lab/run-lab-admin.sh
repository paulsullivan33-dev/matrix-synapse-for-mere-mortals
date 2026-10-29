#!/bin/bash
# Admin shared-secret registration (how users get added when
# public registration is closed), and the data on disk.
BASE=http://127.0.0.1:8008
T=~/workspace/matrix-synapse-for-mere-mortals/matrix-lab/transcripts
W=~/workspace/matrix-lab-work
SECRET=$(grep -oP 'registration_shared_secret: "\K[^"]+' "$W/homeserver.yaml")

{
  echo "# With public registration closed, an admin adds users with"
  echo "# the shared secret from homeserver.yaml. The endpoint first"
  echo "# hands out a one-time nonce; the answer is an HMAC of the"
  echo "# nonce and the new account's details, keyed by the secret."
  echo "# (The secret itself is not printed; it never leaves the server.)"
  echo
  echo "\$ curl -s $BASE/_synapse/admin/v1/register"
  curl -s $BASE/_synapse/admin/v1/register | tee "$W/tokens/nonce.json" | jq .
  NONCE=$(jq -r .nonce "$W/tokens/nonce.json")
  echo
  echo "# The signed message is the fields joined by NUL bytes, ending"
  echo "# in the word 'admin' or 'notadmin'. (The lab checked an"
  echo "# older write-up that said 'user' — the server answered"
  echo "# 'HMAC incorrect'. The word below is the one Synapse"
  echo "# 1.164.1 accepts, read from its own source.)"
  echo "\$ python3 -c '<hmac-sha1 over nonce NUL carol NUL password NUL notadmin, keyed by the shared secret>'"
  MAC=$(python3 - "$NONCE" "$SECRET" <<'PYEOF'
import sys, hmac, hashlib
nonce, secret = sys.argv[1], sys.argv[2].encode()
msg = b"\x00".join([nonce.encode(), b"carol", b"CarolPass!567", b"notadmin"])
print(hmac.new(secret, msg, hashlib.sha1).hexdigest())
PYEOF
)
  echo "mac = $MAC   (computed locally; proves we hold the secret)"
  echo
  echo "\$ curl -s -X POST $BASE/_synapse/admin/v1/register -d '{\"nonce\":\"<nonce>\",\"username\":\"carol\",\"password\":\"CarolPass!567\",\"admin\":false,\"mac\":\"<mac>\"}'"
  curl -s -X POST $BASE/_synapse/admin/v1/register -H 'Content-Type: application/json' \
    -d "{\"nonce\":\"$NONCE\",\"username\":\"carol\",\"password\":\"CarolPass!567\",\"admin\":false,\"mac\":\"$MAC\"}" | jq .
  echo
  echo "# Carol can log in at once — no open registration was needed:"
  echo "\$ curl -s -X POST $BASE/_matrix/client/v3/login -d '{...carol...}'"
  curl -s -X POST $BASE/_matrix/client/v3/login -H 'Content-Type: application/json' \
    -d '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"@carol:lab.local"},"password":"CarolPass!567"}' \
    | jq '{user_id, device_id}'
} > "$T/t13-admin-adds-a-user.txt" 2>&1

{
  echo "# Everything the lab's server owns, on disk:"
  echo
  echo "\$ ls -la (the homeserver data directory)"
  ls -la "$W" | grep -v "^d.*venv\|run-lab\|synapse-stdout\|tokens" 
  echo
  echo "\$ du -h homeserver.db; file homeserver.db"
  du -h "$W/homeserver.db"; file "$W/homeserver.db"
  echo
  echo "\$ ls media_store/   (uploads would live here; the lab sent text only)"
  ls -la "$W/media_store/" 2>/dev/null || find "$W" -name "media_store" -maxdepth 3
  echo
  echo "# The two files that ARE the server's identity and memory:"
  echo "#   lab.local.signing.key — lose it and other servers stop"
  echo "#     trusting this one; homeserver.db — every user, room"
  echo "#     and message the server knows. Back up both, plus the"
  echo "#     config. Sizes above are after 3 users and 2 rooms."
} > "$T/t14-data-on-disk.txt" 2>&1
echo done
