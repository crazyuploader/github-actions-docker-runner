FROM ubuntu:jammy

# Get architecture
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH}

LABEL author="Sergey Torshin @torshin5ergey" \
    description="Custom GitHub Actions runner for Docker" \
    runner-image="Linux" \
    runner-architecture=${TARGETARCH} \
    runner-default-version="2.325.0"

ARG RUNNER_VERSION=2.325.0
ARG RUNNER_HASH_AMD64=5020da7139d85c776059f351e0de8fdec753affc9c558e892472d43ebeb518f4
ARG RUNNER_HASH_ARM64=0e916ad0d354089d320011c132d46bdbe3353c8b925a2e1056c7c8e85d2f2490
ARG RUNNER_HASH_ARM=f74f77c6437c6de3d2921e4b26a6e2e31c21cbdeb309f86648d1f4e5fa0c3eca
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
                    tmux screen jq tree bc

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
