FROM ubuntu:jammy

LABEL author="Sergey Torshin @torshin5ergey" \
    description="Custom GitHub Actions runner for Docker" \
    runner-image="Linux" \
    runner-architecture="x64" \
    runner-default-version="2.322.0"

ARG RUNNER_VERSION=2.322.0
ARG RUNNER_HASH=b13b784808359f31bc79b08a191f5f83757852957dd8fe3dbfcc38202ccf5768
ARG CHECK_HASH=true

WORKDIR /actions-runner

ENV DEBIAN_FRONTEND=noninteractive
ENV REPO_URL=${REPO_URL}

# Install prerequisites
RUN apt update && \
    apt install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download runner package
ADD https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Validate the hash (conditionally)
RUN if [ "${CHECK_HASH}" = "true" ]; then \
    echo "${RUNNER_HASH} actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" | sha256sum -c; \
    fi

# Extract the installer
RUN tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install Dotnet Core 6.0 dependencies
RUN ./bin/installdependencies.sh

# Create runner user
RUN useradd -m runner && chown -R runner:runner /actions-runner
USER runner

# Entrypoint script
COPY --chown=runner:runner entrypoint.sh ./
ENTRYPOINT ["./entrypoint.sh"]
