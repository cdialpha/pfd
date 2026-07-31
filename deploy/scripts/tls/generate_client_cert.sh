#!/bin/bash
# generate_client_cert.sh - Create client certificate
# Usage: ./generate_client_cert.sh username

USERNAME="${1:?Usage: $0 username}"
CLIENT_DIR="${PROJECT_ROOT}/deploy/tls/clients"
CA_DIR="${PROJECT_ROOT}/deploy/tls/ca"

mkdir -p "${CLIENT_DIR}/${USERNAME}"
cd "${CLIENT_DIR}/${USERNAME}"

# Generate client private key
openssl genrsa -out "${USERNAME}.key" 2048
chmod 600 "${USERNAME}.key"

# Create certificate signing request
# The CN (Common Name) will be used as the PostgreSQL username
openssl req -new \
    -key "${USERNAME}.key" \
    -out "${USERNAME}.csr" \
    -subj "/C=US/ST=California/L=San Francisco/O=MyCompany/CN=${USERNAME}"

# Create extension file
cat > client_ext.cnf << EOF
[client_cert]
basicConstraints = CA:FALSE
keyUsage = digitalSignature
extendedKeyUsage = clientAuth
EOF

# Sign with CA and record the certificate in the CA database
openssl ca -batch \
    -config "${CA_DIR}/openssl.cnf" \
    -extensions client_cert \
    -extfile client_ext.cnf \
    -in "${USERNAME}.csr" \
    -out "${USERNAME}.crt" \
    -days 365 \
    -notext

# Create PKCS12 bundle for easy distribution.
# pgJDBC expects the PKCS12 alias to be "user".
# openssl pkcs12 -export \
#     -name user \
#     -in "${USERNAME}.crt" \
#     -inkey "${USERNAME}.key" \
#     -out "${USERNAME}.p12" \
#     -passout pass:changeme

echo "Client certificate created for ${USERNAME}"
echo "Files: ${CLIENT_DIR}/${USERNAME}/${USERNAME}.crt"
echo "       ${CLIENT_DIR}/${USERNAME}/${USERNAME}.key"