#!/bin/bash
# generate_server_cert.sh - Create server certificate

SERVER_DIR="${PROJECT_ROOT}/deploy/tls/server"
CA_DIR="${PROJECT_ROOT}/deploy/tls/ca"
SERVER_HOSTNAME="psql.local"

mkdir -p "${SERVER_DIR}"
cd "${SERVER_DIR}"

# Generate server private key
openssl genrsa -out server.key 2048
chmod 400 server.key

# Create certificate signing request
openssl req -new \
    -key server.key \
    -out server.csr \
    -subj "/C=US/ST=California/L=San Francisco/O=MyCompany/CN=${SERVER_HOSTNAME}"

# Create extension file for SAN (Subject Alternative Names)
cat > server_ext.cnf << EOF
[server_cert]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${SERVER_HOSTNAME}
DNS.2 = localhost
IP.1 = 127.0.0.1
EOF

# Sign with CA and record the certificate in the CA database
openssl ca -batch \
    -config "${CA_DIR}/openssl.cnf" \
    -extensions server_cert \
    -extfile server_ext.cnf \
    -in server.csr \
    -out server.crt \
    -days 365 \
    -notext

# check if user postgres exists, if not create it
id postgres &>/dev/null || sudo useradd -s /bin/bash -u 999 postgres
# Set ownership for PostgreSQL
chmod 600 server.key
chmod 644 server.crt
sudo chown postgres:postgres server.key server.crt

echo "Server certificate created at ${SERVER_DIR}/server.crt"

cd "${DEPLOY_DIR}"