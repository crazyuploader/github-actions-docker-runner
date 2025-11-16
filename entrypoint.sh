#! /bin/bash

set -e

# Check if runner is already configured
# Configure thr runner on first start
if [ ! -f .runner ]; then
    ./config.sh --url "${REPO_URL}" --token "${TOKEN}"
    touch .runner
fi

# Start the runner
exec ./run.sh
