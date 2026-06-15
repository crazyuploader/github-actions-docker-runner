#! /bin/bash

set -e

CONFIG_DIR="${RUNNER_CONFIG_DIR:-/runner-config}"
CONFIG_FILES=(.runner .credentials .credentials_rsaparams)

if [ ! -f "${CONFIG_DIR}/.runner" ]; then
    ./config.sh --url "${RUNNER_URL}" --token "${TOKEN}"
    mkdir -p "${CONFIG_DIR}"
    cp "${CONFIG_FILES[@]}" "${CONFIG_DIR}/"
else
    cp "${CONFIG_FILES[@]/#/${CONFIG_DIR}/}" .
fi

exec ./run.sh
