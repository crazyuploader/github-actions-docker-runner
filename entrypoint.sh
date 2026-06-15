#! /bin/bash

set -e

CONFIG_DIR="${RUNNER_CONFIG_DIR:-/runner-config}"
CONFIG_FILES=(.runner .credentials .credentials_rsaparams)

# The persist dir is usually a bind mount created as root on the host.
# Make it writable by the unprivileged runner user.
mkdir -p "${CONFIG_DIR}"
chown runner:runner "${CONFIG_DIR}"

# Restore persisted registration, if any.
if [ -f "${CONFIG_DIR}/.runner" ]; then
    cp "${CONFIG_FILES[@]/#/${CONFIG_DIR}/}" .
    chown runner:runner "${CONFIG_FILES[@]}"
fi

# Register only when not already configured locally. Checking the local
# .runner (not the persisted copy) avoids a re-register crash loop if a
# previous run registered but failed to persist.
if [ ! -f .runner ]; then
    gosu runner ./config.sh --url "${RUNNER_URL}" --token "${TOKEN}" --unattended --replace
    cp "${CONFIG_FILES[@]}" "${CONFIG_DIR}/"
    chown runner:runner "${CONFIG_FILES[@]/#/${CONFIG_DIR}/}"
fi

exec gosu runner ./run.sh
