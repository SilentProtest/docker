#!/bin/bash
# Generate a self-signed x509 certificate or certificate signing request and
# key using OpenSSL. DNS and IP addresses can be added as subjectAltName
# entries.
#
# Usage:
#   ./gencert.sh <common name (or DNS name)> <DNS names or ip addresses...> [--rsa4096] [--csr]
#
# By default, a 2048 bits RSA key is generated. Supply --rsa4096 at the end to
# generate a 4096 bits key.
#
# To generate a certificate signing request instead of a self-signed
# certificate, supply --csr at the end.
#
# Example:
#
#   ./gencert.sh mutalyzer.nl mutalyzer.nl test.mutalyzer.nl api.mutalyzer.nl
#
# If you specify a DNS name for common name, be aware that you should still
# also include it in the list of DNS names or ip addresses.
#
# 2015, Martijn Vermaat <martijn@vermaat.name>

set -o nounset
set -o errexit
set -o pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <common name (or DNS name)> <DNS names or ip addresses...> [--rsa4096] [--csr]"
    exit 1
fi

common_name="$1"
args="${@:2}"
config="$(mktemp)"
mode="certificate"
keytype="rsa:2048"

dnss=
ips=
for arg in ${args}; do
    if [[ "${arg}" == "--rsa4096" ]]; then
        keytype="rsa:4096"
    elif [[ "${arg}" == "--csr" ]]; then
        mode="csr"
    elif [[ "${arg}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        ips+="${arg} "
    else
        dnss+="${arg} "
    fi
done

altnames=
subjectaltline=

i=0
for dns in ${dnss}; do
    i=$(($i+1))
    altnames+="DNS.${i} = ${dns}"$'\n'
    subjectaltline="subjectAltName = @alt_names"
done

i=0
for ip in ${ips}; do
    i=$(($i+1))
    altnames+="IP.${i} = ${ip}"$'\n'
    subjectaltline="subjectAltName = @alt_names"
done

cat >"${config}" <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = NA
ST = NA
L = NA
O = NA
CN = ${common_name}

[v3_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:TRUE
${subjectaltline}

[v3_req]
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
basicConstraints = CA:FALSE
${subjectaltline}

[alt_names]
${altnames}
EOF

if [ "${mode}" == "csr" ]; then
    openssl req -new -batch -nodes -sha256 -newkey "${keytype}" \
            -config "${config}" \
            -keyout "${common_name}.key" \
            -out "${common_name}.csr"
    openssl req -in "${common_name}.csr" -noout -text
else
    openssl req -x509 -batch -nodes -sha256 -newkey "${keytype}" -days 3650 \
            -config "${config}" \
            -keyout "${common_name}.key" \
            -out "${common_name}.crt"
    openssl x509 -in "${common_name}.crt" -noout -text
fi
