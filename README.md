# Custom GitHub Actions Runner in Docker

This repository provides a Dockerized [self-hosted GitHub Actions runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners) based on a Linux image with x64 architecture.

## Table of contents

- [Table of contents](#table-of-contents)
- [TL;DR](#tldr)
- [Build](#build)
- [Setup and Run](#setup-and-run)
  - [Step 1: Setup the runner](#step-1-setup-the-runner)
  - [Step 2: Use the runner](#step-2-use-the-runner)
- [Docker container configuration](#docker-container-configuration)
  - [Environment variables](#environment-variables)
- [License](#license)
- [Author](#author)

## TL;DR

```bash
REPO_URL=<https://github.com/username/repo>
REPO_NAME=$(basename -s .git "$REPO_URL")
docker run -d \
  --name "actions-runner-$REPO_NAME" \
  -e REPO_URL="$REPO_URL" \
  -e TOKEN="<token>" \
  torshin5ergey/actions-runner:latest
```

Replace `<https://github.com/username/repo>` with your repository URL and `<token>` with a valid GitHub token.

## Build

To build the Docker image locally, navigate to the repository directory and run

```bash
docker build -t actions-runner .
```

## Setup and Run

### Step 1: Setup the runner

To run GitHub Actions Runner in Docker, you need to provide your repository URL and a token for authentication. Replace `<https://github.com/username/repo>` and `<token>` with your data.

```bash
REPO_URL=<https://github.com/username/repo>
REPO_NAME=$(basename -s .git "$REPO_URL")

docker run -d \
  --name "actions-runner-$REPO_NAME" \
  -e REPO_URL="$REPO_URL" \
  -e TOKEN="<token>" \
  torshin5ergey/actions-runner:latest
```

### Step 2: Use the runner

Use this YAML in your workflow file for each job

```yaml
runs-on: self-hosted
```

## Docker container configuration

### Environment variables

The following environment variables can be configured.

| Name             | Description                                                                                                                           | Default value                                                   |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `REPO_URL`       | The URL of the GitHub repository where the runner will be registered.                                                                 | -                                                               |
| `TOKEN`          | A GitHub token with permissions to register the runner. _Can be found on Repo Settings > Actions > Runners > New self-hosted runner._ | -                                                               |
| `RUNNER_VERSION` | The version of the GitHub Actions runner to download.                                                                                 | `2.322.0`                                                       |
| `CHECK_HASH`     | Set to `true` to enable hash validation (requires specifying corresponding `RUNNER_HASH` hash value).                                 | `true`                                                          |
| `RUNNER_HASH`    | The SHA256 hash for the specified runner version for validation. Only used if the `CHECK_HASH` is `true`                              | `b13b7848...` _the entire value can be found in the Dockerfile_ |

## License

This project is licensed under the [MIT License](https://github.com/torshin5ergey/github-actions-docker-runner/blob/main/LICENSE).

## Author

Sergey Torshin [@torshin5ergey](https://github.com/torshin5ergey)
