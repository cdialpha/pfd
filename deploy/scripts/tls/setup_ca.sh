#!/bin/bash
# setup_ca.sh - Create a Certificate Authority

# PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# PROJECT_ROOT comes from parent script (e.g., deploy/scripts/up.sh)

CA_DIR="${PROJECT_ROOT}/deploy/tls/ca"

mkdir -p "${CA_DIR}/certs" "${CA_DIR}/newcerts"
cd "${CA_DIR}"
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

cat > openssl.cnf << EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir = ${CA_DIR}
certs = \$dir/certs
new_certs_dir = \$dir/newcerts
database = \$dir/index.txt
serial = \$dir/serial
crlnumber = \$dir/crlnumber
certificate = \$dir/ca.crt
private_key = \$dir/ca.key
default_md = sha256
default_days = 365
default_crl_days = 30
policy = policy_any
unique_subject = no

[ policy_any ]
countryName = optional
stateOrProvinceName = optional
localityName = optional
organizationName = optional
organizationalUnitName = optional
commonName = supplied
emailAddress = optional
EOF

# Generate CA private key
openssl genrsa -out ca.key 4096

# Generate CA certificate (valid for 10 years)
openssl req -new -x509 \
    -days 3650 \
    -key ca.key \
    -out ca.crt \
    -addext "basicConstraints = critical, CA:TRUE" \
    -addext "keyUsage = critical, keyCertSign, cRLSign" \
    -subj "/C=US/ST=California/L=San Francisco/O=MyCompany/CN=PostgreSQL CA"

# Secure the CA key
chmod 400 ca.key
chmod 444 ca.crt

echo "CA certificate created at ${CA_DIR}/ca.crt"