FROM ubuntu:noble

# Get architecture
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH}

LABEL author="@crazyuploader" \
    description="Custom GitHub Actions runner for Docker" \
    runner-image="Linux" \
    runner-architecture=${TARGETARCH} \
    runner-default-version="2.331.0"

ARG RUNNER_VERSION=2.331.0
ARG RUNNER_HASH_AMD64=5fcc01bd546ba5c3f1291c2803658ebd3cedb3836489eda3be357d41bfcf28a7
ARG RUNNER_HASH_ARM64=f5863a211241436186723159a111f352f25d5d22711639761ea24c98caef1a9a
ARG RUNNER_HASH_ARM=f233d41c2080d9c8ae7533857c4ff6a3d3d7102632ce441fc400e0339c5b76cc
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
