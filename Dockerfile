FROM ubuntu:noble

# Get architecture
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH}

LABEL author="Sergey Torshin @torshin5ergey" \
    description="Custom GitHub Actions runner for Docker" \
    runner-image="Linux" \
    runner-architecture=${TARGETARCH} \
    runner-default-version="2.327.1"

ARG RUNNER_VERSION=2.327.1
ARG RUNNER_HASH_AMD64=d68ac1f500b747d1271d9e52661c408d56cffd226974f68b7dc813e30b9e0575
ARG RUNNER_HASH_ARM64=16102096988246f250a745c6a813a5a0b8901e2f554f9440c97e8573fd4da111
ARG RUNNER_HASH_ARM=b6f34af6d11f5f023fe23aa8bcb01f392eaad30d70e1e31f4e68bbdbb315eda8
ARG CHECK_HASH=true

WORKDIR /actions-runner

ENV DEBIAN_FRONTEND=noninteractive

ARG REPO_URL
ENV REPO_URL=${REPO_URL}


# Update packages list and install common dependencies
RUN apt-get update && \
    apt-get -y autoremove --purge && \
    apt-get install -y --no-install-recommends \
                    git curl wget zip unzip nano tar zip unzip \
                    mtr-tiny dnsutils iputils-ping traceroute \
                    python3 python-is-python3 locales-all \
                    gpg openssh-client xz-utils ca-certificates \
                    tmux screen jq tree bc build-essential

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Download runner package based on architecture
RUN case "${TARGETARCH}" in \
        "amd64") \
            RUNNER_FILENAME="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"; \
            RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILENAME}"; \
            RUNNER_HASH="${RUNNER_HASH_AMD64}"; \
            ;; \
        "arm64") \
            RUNNER_FILENAME="actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz"; \
            RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILENAME}"; \
            RUNNER_HASH="${RUNNER_HASH_ARM64}"; \
            ;; \
        "arm") \
            RUNNER_FILENAME="actions-runner-linux-arm-${RUNNER_VERSION}.tar.gz"; \
            RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILENAME}"; \
            RUNNER_HASH="${RUNNER_HASH_ARM}"; \
            ;; \
        *) \
            echo "Unsupported architecture: ${TARGETARCH}"; \
            exit 1; \
            ;; \
    esac; \
    wget -q -O "${RUNNER_FILENAME}" "${RUNNER_URL}" && \
    if [ "${CHECK_HASH}" = "true" ]; then \
        echo "${RUNNER_HASH} ${RUNNER_FILENAME}" | sha256sum -c; \
    fi && \
    tar xzf "./${RUNNER_FILENAME}" && \
    rm "./${RUNNER_FILENAME}"

# Install Dotnet Core 6.0 dependencies
RUN ./bin/installdependencies.sh

# Create runner user
RUN useradd -m runner && chown -R runner:runner /actions-runner
USER runner

# Entrypoint script
COPY --chown=runner:runner entrypoint.sh ./
ENTRYPOINT ["./entrypoint.sh"]
