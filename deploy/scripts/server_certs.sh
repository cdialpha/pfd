#!/usr/bin/env bash
set -euo pipefail 
shopt -s inherit_errexit
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
load_env
 
CA_DIR="${PROJECT_ROOT}/deploy/tls/ca"
TLS_SERVER_DIR="${PROJECT_ROOT}/deploy/tls/server"
SERVER_HOSTNAME="psql.local"

mkdir -p "$TLS_SERVER_DIR"
umask 077
csr="$(mktemp)"
trap 'rm -f "$csr"' EXIT
 
openssl req -new -nodes \
  -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
  -keyout "$TLS_SERVER_DIR/tls.key" -out "$csr" \
  -subj "/CN=${SERVER_CN:-localhost}" 2>/dev/null
 
# -set_serial avoids a ca.srl side-effect file
openssl x509 -req -in "$csr" -CA "$CA_DIR/ca.crt" -CAkey "$CA_DIR/ca.key" \
  -set_serial "0x$(openssl rand -hex 16)" -days 825 -out "$TLS_SERVER_DIR/tls.crt" \
  -extfile <(printf '%s\n' \
    "subjectAltName=${SERVER_SANS:-DNS:localhost,IP:127.0.0.1}" \
    "extendedKeyUsage=serverAuth" \
    "keyUsage=critical,digitalSignature") 2>/dev/null

# check if user postgres exists, if not create it
id postgres &>/dev/null || sudo useradd -s /bin/bash -u 999 postgres

# Set ownership for PostgreSQL
chmod 600 "$TLS_SERVER_DIR/tls.key"
chmod 644 "$TLS_SERVER_DIR/tls.crt"

# chown postgres:postgres "$TLS_SERVER_DIR/tls.key" "$TLS_SERVER_DIR/tls.crt"
 
ok "server cert -> ${TLS_SERVER_DIR#"$PROJECT_ROOT"/}"

# Sign with CA and record the certificate in the CA database
# openssl ca -batch \
#     -config "${CA_DIR}/openssl.cnf" \
#     -extensions server_cert \
#     -extfile server_ext.cnf \
#     -in server.csr \
#     -out server.crt \
#     -days 365 \
#     -notext
