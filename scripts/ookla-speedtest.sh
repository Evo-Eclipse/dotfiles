#!/usr/bin/env bash
set -euo pipefail

OUT="$(realpath "${1:-./speedtest-results.json}")"

podman run --rm \
    --network=host \
    -v "$(dirname "$OUT"):/out:Z" \
    registry.opensuse.org/opensuse/tumbleweed:latest \
    bash -euc '
        zypper -n install wget tar

        mkdir -p /etc/ssl/certs
        ln -sf /etc/ssl/ca-bundle.pem /etc/ssl/certs/ca-certificates.crt

        wget "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz" \
            -O /tmp/speedtest.tgz
        tar -xzf /tmp/speedtest.tgz -C /usr/local/bin/ speedtest

        echo "Running Ookla speedtest..." >&2
        speedtest --format=json --accept-license --accept-gdpr > /tmp/result.json

        cat /tmp/result.json >&2
        mv /tmp/result.json /out/'"$(basename "$OUT")"'
    '

echo "Done: $OUT"
