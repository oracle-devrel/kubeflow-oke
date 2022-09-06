#! /bin/bash
# Copyright (c) 2022, Oracle and/or its affiliates.

if [ ! -d "$HOME/kubeflow-ssl" ]; then
    mkdir "$HOME/kubeflow-ssl"
fi

cd "$HOME/kubeflow-ssl" || exit 1

# 1. Retrieve the external IP address of the load balancer and use it to create a nip.io FQDN

IP_ADDR=$(kubectl get svc istio-ingressgateway -n istio-system -o=jsonpath="{.status.loadBalancer.ingress[0].ip}")
DOMAIN="${IP_ADDR}.nip.io"

# 2. Create root CA private and public key pair

openssl req -x509 \
            -sha256 -days 356 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=${DOMAIN}/C=US/L=San Fransisco" \
            -keyout rootCA.key -out rootCA.crt

# 3. Create certificate signing request (CSR) config file

cat > csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = US
ST = California
L = San Fransisco
O = Kubeflow
OU = Kubeflow
CN = ${DOMAIN}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${DOMAIN}
IP.1 = ${IP_ADDR}
EOF

# 4. generate a private key

openssl genrsa -out "${DOMAIN}.key" 2048

# 5. create a certificate signing request using the private key and configuration file

openssl req -new -key "${DOMAIN}.key" -out "${DOMAIN}.csr" -config csr.conf

# 6. create a certificate generation configuration file

cat > cert.conf <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN}
IP.1 = ${IP_ADDR}
EOF

# Create certificate signed by the self-signed CA created in step 1

openssl x509 -req \
    -in "${DOMAIN}.csr" \
    -CA rootCA.crt -CAkey rootCA.key \
    -CAcreateserial -out "${DOMAIN}.crt" \
    -days 365 \
    -sha256 -extfile cert.conf