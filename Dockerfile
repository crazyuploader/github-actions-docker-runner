FROM ubuntu:noble

# Get architecture
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH}

LABEL author="@crazyuploader" \
    description="Custom GitHub Actions runner for Docker" \
    runner-image="Linux" \
    runner-architecture=${TARGETARCH} \
    runner-default-version="2.333.0"

ARG RUNNER_VERSION=2.333.0
ARG RUNNER_HASH_AMD64=7ce6b3fd8f879797fcc252c2918a23e14a233413dc6e6ab8e0ba8768b5d54475
ARG RUNNER_HASH_ARM64=b5697062a13f63b44f869de9369638a7039677b9e0f87e47a6001a758c0d09bf
ARG RUNNER_HASH_ARM=370383a927b3fb61f5b892e0f87eda277b6826eec3dbd17d320f8a472560cec8
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
                    tmux screen jq tree bc build-essential clang

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
    curl -fsSL -o "${RUNNER_FILENAME}" "${RUNNER_URL}" && \
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
