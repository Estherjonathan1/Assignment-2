# Assignment 2 - Dockerized Diagnostic CLI

A diagnostic tool packaged as a Docker image, built on top of the Assignment 1 scripts.

## Requirements

- Docker (tested with Docker Desktop's WSL2 integration)
- Docker Compose

## Setup

    git clone <your-repository-url>
    cd <repository>
    chmod +x app/*.sh test.sh
    docker build -t diagnostic-tool .

## Usage

    docker run --rm diagnostic-tool system
    docker run --rm diagnostic-tool network <host>
    docker run --rm diagnostic-tool disk
    docker run --rm diagnostic-tool help

Running with no command defaults to `help`.

### Docker Compose

    docker compose run --rm diagnostic system
    docker compose run --rm diagnostic help

## Exit codes

| Exit code | Meaning |
|-----------|---------|
| 0 | Success |
| 1 | Operational/runtime failure (e.g. host unreachable) |
| 2 | Invalid command or input |

## Health check

The image defines a `HEALTHCHECK` that runs `app/health-check.sh`, which confirms `diagnostic.sh system` runs successfully inside the container.

## Testing

Run the grading script:

    ./grade.sh

Or the test suite directly against the built image:

    ./test.sh

`test.sh` covers `help`, `system`, `disk` and invalid-command handling.

## Assumptions

- The base image is Alpine Linux 3.20, with `bash`, `iputils` (for `ping`) and `procps` installed.
- A path or host that does not exist, or an unknown command, is treated as invalid input (exit code 2).
- Network checks may fail in restricted environments that block outbound connections.
