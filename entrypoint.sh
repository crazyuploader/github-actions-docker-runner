#! /bin/bash

# Check if runner is already configured

set -e

# Configure thr runner on first start
if [ ! -f .runner ]; then
    ./config.sh --url "${REPO_URL}" --token "${TOKEN}"
    touch .runner
fi

# Start the runner
exec ./run.sh
