# GitHub Actions Runner in Docker

Dockerized self-hosted GitHub Actions runner. Supports `linux/amd64` and `linux/arm64`.

## Usage

### 1. Get a registration token

**Repository runner:** `Repo → Settings → Actions → Runners → New self-hosted runner`

**Org runner:** `Org → Settings → Actions → Runners → New self-hosted runner`

### 2. Configure `docker-compose.yml`

```yaml
services:
  actions-runner:
    container_name: actions-runner-<NAME>
    image: ghcr.io/crazyuploader/actions-runner:latest
    restart: unless-stopped
    environment:
      - RUNNER_URL=<RUNNER_URL> # repo: https://github.com/ORG/REPO
                                # org:  https://github.com/ORG
      - TOKEN=<ACTIONS_RUNNER_TOKEN>
    volumes:
      - ./runner-config:/runner-config
    # deploy:
    #   resources:
    #     limits:
    #       cpus: "2.0"
    #       memory: 4g
    #     reservations:
    #       cpus: "0.5"
    #       memory: 512m
    logging:
      options:
        max-size: 64m
```

### 3. Start

```bash
docker compose up -d
```

You only need the token on first start. Credentials persist in `./runner-config/` and survive container updates and restarts.

### 4. Use the runner in workflows

```yaml
jobs:
  build:
    runs-on: self-hosted
```

## Environment variables

| Variable            | Description                                                          |
| ------------------- | -------------------------------------------------------------------- |
| `RUNNER_URL`        | Repository or org URL to register the runner against                 |
| `TOKEN`             | One-time registration token (only used if `runner-config/` is empty) |
| `RUNNER_CONFIG_DIR` | Override config persistence path (default: `/runner-config`)         |

## License

[MIT](LICENSE)
