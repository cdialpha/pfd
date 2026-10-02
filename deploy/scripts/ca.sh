#!/usr/bin/env bash
# setup_ca.sh - Create a Certificate Authority
set -euo pipefail 
shopt -s inherit_errexit
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
load_env

CA_DIR="${PROJECT_ROOT}/deploy/tls/ca"
mkdir -p "${CA_DIR}"
umask 077

openssl req -x509 -new -noenc \
  -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
  -keyout "$CA_DIR/ca.key" -out "$CA_DIR/ca.crt" -days 3650 \
  -subj "/CN=${CA_CN:-local-dev-ca}" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,keyCertSign,cRLSign"

chmod 644 "$CA_DIR/ca.crt"
ok "CA -> ${CA_DIR#"$PROJECT_ROOT"/}"

# # Secure the CA key
# chmod 400 ${CA_DIR}/ca.key
# chmod 444 ${CA_DIR}/ca.crt

# ok "CA certificate created at ${CA_DIR}/ca.crt"