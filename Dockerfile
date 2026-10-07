FROM ubuntu:resolute

# Get architecture
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH}

LABEL author="@crazyuploader" \
    description="Custom GitHub Actions runner for Docker" \
    runner-image="Linux" \
    runner-architecture=${TARGETARCH} \
    runner-default-version="2.335.1"

ARG RUNNER_VERSION=2.338.0
ARG RUNNER_HASH_AMD64=af4b794c1bc41d73d40535e3fe092a39f9679cd8d965954c2aca25a05ca41d32
ARG RUNNER_HASH_ARM64=628b4a7258487b80c1d3c221095a7ded349f5ae0175fd3dfab708d07428f041b
ARG CHECK_HASH=true

WORKDIR /actions-runner

ENV DEBIAN_FRONTEND=noninteractive

# Update packages list and install common dependencies
RUN apt-get update && \
    apt-get -y autoremove --purge && \
    apt-get install -y --no-install-recommends \
                    git curl wget zip unzip nano tar gosu \
                    mtr-tiny dnsutils iputils-ping traceroute \
                    python3 python-is-python3 locales-all \
                    gpg openssh-client xz-utils ca-certificates \
                    tmux screen jq tree bc build-essential clang \
                    libglib2.0-0 libnss3 libnspr4 libdbus-1-3 libatk1.0-0 libatk-bridge2.0-0 \
                    libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 \
                    libxrandr2 libgbm1 libasound2t64 libpango-1.0-0 libcairo2 libx11-6 \
                    libxcb1 libxext6 fonts-liberation

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Download runner package based on architecture
RUN case "${TARGETARCH}" in \
        "amd64") \
            RUNNER_FILENAME="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"; \
            DOWNLOAD_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILENAME}"; \
            RUNNER_HASH="${RUNNER_HASH_AMD64}"; \
            ;; \
        "arm64") \
            RUNNER_FILENAME="actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz"; \
            DOWNLOAD_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILENAME}"; \
            RUNNER_HASH="${RUNNER_HASH_ARM64}"; \
            ;; \
        *) \
            echo "Unsupported architecture: ${TARGETARCH}"; \
            exit 1; \
            ;; \
    esac; \
    curl -fsSL -o "${RUNNER_FILENAME}" "${DOWNLOAD_URL}" && \
    if [ "${CHECK_HASH}" = "true" ]; then \
        echo "${RUNNER_HASH} ${RUNNER_FILENAME}" | sha256sum -c; \
    fi && \
    tar xzf "./${RUNNER_FILENAME}" && \
    rm "./${RUNNER_FILENAME}"

# Install Dotnet Core 6.0 dependencies
RUN ./bin/installdependencies.sh

# Create runner user
RUN useradd -m runner && chown -R runner:runner /actions-runner

# Entrypoint runs as root to fix bind-mount ownership, then drops to the
# runner user via gosu. The runner itself never runs as root.
COPY --chown=runner:runner entrypoint.sh ./
ENTRYPOINT ["./entrypoint.sh"]
