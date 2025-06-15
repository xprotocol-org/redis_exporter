#!/bin/bash

# Generate test certificates:
#
#   ca.{crt,key}          Self signed CA certificate.
#   redis.{crt,key}       A certificate with no key usage/policy restrictions.

dir=`dirname $0`

# Generate CA
if [ ! -f "${dir}/ca.key" ] || [ ! -f "${dir}/ca.crt" ]; then
    echo "Generating CA certificate..."
    openssl genrsa -out ${dir}/ca.key 4096
    openssl req \
        -x509 -new -nodes -sha256 \
        -key ${dir}/ca.key \
        -days 3650 \
        -subj '/O=redis_exporter/CN=Certificate Authority' \
        -out ${dir}/ca.crt
    echo "CA certificate generated."
else
    echo "CA certificate already exists, skipping generation."
fi

# Generate cert
if [ ! -f "${dir}/redis.key" ] || [ ! -f "${dir}/redis.crt" ]; then
    echo "Generating Redis certificate..."
    openssl genrsa -out ${dir}/redis.key 2048
    openssl req \
        -new -sha256 \
        -subj "/O=redis_exporter/CN=localhost" \
        -key ${dir}/redis.key | \
        openssl x509 \
            -req -sha256 \
            -CA ${dir}/ca.crt \
            -CAkey ${dir}/ca.key \
            -CAserial ${dir}/ca.txt \
            -CAcreateserial \
            -days 3650 \
            -out ${dir}/redis.crt
    echo "Redis certificate generated."
else
    echo "Redis certificate already exists, skipping generation."
fi
