#!/bin/bash -f
# Copyright (c) 2022, Oracle and/or its affiliates.
KF_VERSION_BRANCH_NAME=1.8
KUSTOMIZE_VERSION=5.1.0
# setup KF and download
cd $HOME
mkdir kubeflow
echo "Setting up kustomize"
KUSTOMIZE_INSTALL=$HOME/kubeflow/install_kustomize.sh
curl -s -o $KUSTOMIZE_INSTALL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" 
chmod +x $KUSTOMIZE_INSTALL
bash $KUSTOMIZE_INSTALL $KUSTOMIZE_VERSION
# download the entire kubeflow system
echo "getting kubeflow"
git clone https://github.com/kubeflow/manifests.git kubeflow-$KF_VERSION_BRANCH_NAME
cd kubeflow-$KF_VERSION_BRANCH_NAME
echo "Checking out branch $KF_VERSION_BRANCH_NAME"
git checkout $KF_VERSION_BRANCH_NAME
# almost certainly un needed, but just to be safe
git pull origin
# is this needed in the cloud shell ?
# doesn't seem to be ion my setup
echo "Generating password"
# sudo yum install httpd-tools -y
PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
echo "The password for user@example.com is  $PASSWD"
KF_PASSWD=$(htpasswd -nbBC 12 USER $PASSWD| sed -r 's/^.{5}//')
# echo $KF_PASSWD 
# Taken note of this output
cd $HOME/kubeflow-$KF_VERSION_BRANCH_NAME
sed -i.orig "s|DEX_USER_PASSWORD:.*|DEX_USER_PASSWORD: $KF_PASSWD|" common/dex/base/dex-passwords.yaml

# do the actual install
echo "Starting kubeflow install, this may take a while"

while ! $HOME/kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done


# Once it's suceeded do this in s separate directory so we can change things easily
cd $HOME/kubeflow
# Patch to loadbalancer
echo "Generating load balancer patch with OCI specific annotations"
cat <<EOF | tee $HOME/kubeflow/patchservice_lb.yaml
  spec:
    type: LoadBalancer
  metadata:
    annotations:
      oci.oraclecloud.com/load-balancer-type: "lb"
      service.beta.kubernetes.io/oci-load-balancer-shape: "flexible"
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-min: "10"
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-max: "100"
EOF

# apply the patch
echo "Applying load balancer patsh to the istio gateway"
kubectl patch svc istio-ingressgateway -n istio-system -p "$(cat $HOME/kubeflow/patchservice_lb.yaml)"

mkdir $HOME/kubeflow/ssl
cd $HOME/kubeflow/ssl
echo "Creating certificates for the load balancer"
#create the certificate for the LB IP
# wait for the LB IP
while [ -z "$IP_ADDR" ]; do
  echo "Looking for IP address for service istio-ingressgateway load balancer"
  IP_ADDR=$(kubectl get svc istio-ingressgateway -n istio-system -o=jsonpath="{.status.loadBalancer.ingress[0].ip}")
done
DOMAIN="${IP_ADDR}.nip.io"

# create the cert signing request
openssl req -x509             -sha256 -days 356             -nodes             -newkey rsa:2048             -subj "/CN=${DOMAIN}/C=US/L=San Fransisco"             -keyout rootCA.key -out rootCA.crt
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

# generate a cert
openssl genrsa -out "${DOMAIN}.key" 2048
openssl req -new -key "${DOMAIN}.key" -out "${DOMAIN}.csr" -config csr.conf

cat > cert.conf <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${DOMAIN}
IP.1 = ${IP_ADDR}
EOF

# start signing things
openssl x509 -req     -in "${DOMAIN}.csr"     -CA rootCA.crt -CAkey rootCA.key     -CAcreateserial -out "${DOMAIN}.crt"     -days 365     -sha256 -extfile cert.conf

#create the secret
kubectl create secret tls kubeflow-tls-cert --key=$DOMAIN.key --cert=$DOMAIN.crt -n istio-system

echo "Updating the ingress with the generated certificate"
# patch the istio gateway
cat <<EOF | tee $HOME/kubeflow/sslenableingress.yaml
apiVersion: v1
items:
- apiVersion: networking.istio.io/v1beta1
  kind: Gateway
  metadata:
    annotations:
    name: kubeflow-gateway
    namespace: kubeflow
  spec:
    selector:
      istio: ingressgateway
    servers:
    - hosts:
      - "*"
      port:
        name: https
        number: 443
        protocol: HTTPS
      tls:
        mode: SIMPLE
        credentialName: kubeflow-tls-cert
    - hosts:
      - "*"
      port:
        name: http
        number: 80
        protocol: HTTP
      tls:
        httpsRedirect: true
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""
EOF

# apply the patch
kubectl apply -f $HOME/kubeflow/sslenableingress.yaml
# and you're done

echo "Your kubeflow dashboard is at https://$DOMAIN"
echo "Login as user@example.com"
echo This is your kubeflow password for user user@example.com
echo $PASSWD

