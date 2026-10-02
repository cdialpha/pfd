#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
load_env

echo "NET=[$KIND_NET] SUBNET=[$KIND_SUBNET] GW=[$KIND_GW]" >&2

if ! docker network inspect "$KIND_NET" >/dev/null 2>&1; then
  docker network create -d bridge --subnet "$KIND_SUBNET" --gateway "$KIND_GW" "$KIND_NET" >/dev/null
  ok "created network $KIND_NET ($KIND_SUBNET)"
  exit 0
fi

existing="$(docker network inspect "$KIND_NET" -f '{{ (index .IPAM.Config 0).Subnet }}')"
[[ "$existing" == "$KIND_SUBNET" ]] || die \
  "network '$KIND_NET' has subnet $existing, expected $KIND_SUBNET - run: make down PURGE=1"

ok "network $KIND_NET ($KIND_SUBNET) exists"